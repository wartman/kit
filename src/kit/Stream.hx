package kit;

import haxe.Exception;

enum StreamMessage<T, E> {
	Continue;
	Pause;
	Done;
	Clog(error:E);
	Error(error:E);
}

enum StreamStep<T, E> {
	Next(item:T, next:Stream<T, E>);
	Done;
	Error(error:E);
}

enum Yield<T, E = Error> {
	Data(item:T);
	Error(error:E);
	Done;
}

enum StreamResult<T, E> {
	Depleted;
	Paused(next:Stream<T, E>);
	Clogged(error:E, next:Stream<T, E>);
	Errored(error:E);
}

enum StreamReduction<T, R, E> {
	Reduced(value:R);
	Errored(error:E);
	Clogged(error:E, next:Stream<T, E>);
}

abstract StreamHandler<T, E>((item:T) -> Future<StreamMessage<T, E>>) from (item:T) -> Future<StreamMessage<T, E>> {
	@:from
	public static function ofVoidFunction<T, E>(fn:(item:T) -> Void) {
		return new StreamHandler(item -> {
			fn(item);
			return Future.immediate(Continue);
		});
	}

	@:from
	public static function ofSync<T, E>(fn:(item:T) -> StreamMessage<T, E>) {
		return new StreamHandler(item -> Future.immediate(fn(item)));
	}

	public function new(handler) {
		this = handler;
	}

	@:op(a())
	public inline function call(item) {
		return this(item);
	}
}

@:forward
abstract Stream<T, E = Error>(StreamObject<T, E>) from StreamObject<T, E> {
	@:noUsing
	@:from
	public static function lazy<T, E>(future:Future<Stream<T, E>>):Stream<T, E> {
		return new LazyStream(future);
	}

	@:noUsing public static function generator<T, E>(handler:Future.FutureActivator<StreamStep<T, E>>):Stream<T, E> {
		return new GeneratorStream(new Future(handler));
	}

	@:noUsing public static function empty<T, E>():Stream<T, E> {
		return new EmptyStream();
	}

	@:noUsing public static function value<T, E>(item:T):Stream<T, E> {
		return new ValueStream(item);
	}

	@:noUsing public static function error<T, E>(error:E):Stream<T, E> {
		return new ErroredStream(error);
	}

	@:noUsing public static function event<T, E>(event:Event<Yield<T, E>>) {
		return new GeneratorStream(new Future(activate -> {
			event.addOnce(yield -> switch yield {
				case Data(item): activate(Next(item, Stream.event(event)));
				case Error(error): activate(Error(error));
				case Done: activate(Done);
			});
		}).eager());
	}

	#if nodejs
	@:noUsing
	@:from
	public static function ofNodeReadable<T>(readable:js.node.stream.Readable.IReadable):Stream<T, Error> {
		var event = new Event<Yield<T>>();
		var stream = Stream.event(event);

		readable.once('end', () -> event.dispatch(Done));
		readable.once('error', (e:{code:String, message:String}) -> {
			event.dispatch(Error(new Error(InternalError, '${e.code}: Stream failed with ${e.message}')));
		});
		readable.on('data', data -> event.dispatch(Data(data)));

		return stream;
	}
	#end

	@:from
	@:noUsing
	public inline static function ofArray<T, E>(arr:Array<T>):Stream<T, E> {
		return ofIterator(arr.iterator());
	}

	@:from
	@:noUsing
	public static function ofIterator<T, E>(iterator:Iterator<T>):Stream<T, E> {
		function next(step:(step:StreamStep<T, E>) -> Void) {
			step(if (iterator.hasNext()) {
				Next(iterator.next(), generator(next));
			} else {
				Done;
			});
		}
		return generator(next);
	}

	@:from
	@:noUsing
	public static function ofTask<T, E>(task:Task<T, E>):Stream<T, E> {
		return generator(yield -> {
			task.handle(result -> switch result {
				case Ok(value): yield(Next(value, empty()));
				case Error(error): yield(Error(error));
			});
		});
	}
}

abstract class StreamObject<T, E> {
	public function isDepleted():Bool {
		return false;
	}

	public function prepend(other:Stream<T, E>):Stream<T, E> {
		if (isDepleted()) return other;
		return new CompoundStream([other, this]);
	}

	public function append(other:Stream<T, E>):Stream<T, E> {
		if (isDepleted()) return other;
		return new CompoundStream([this, other]);
	}

	public function map<R>(transform:(value:T) -> Task<R, E>):Stream<R, E> {
		return new GeneratorStream(next().flatMap(step -> switch step {
			case Next(item, next):
				transform(item).flatMap(result -> switch result {
					case Ok(value): Future.immediate(StreamStep.Next(value, next.map(transform)));
					case Error(error): Future.immediate(StreamStep.Error(error));
				});
			case Done: Future.immediate(StreamStep.Done);
			case Error(error): Future.immediate(StreamStep.Error(error));
		}));
	}

	public function reduce<R>(accumulator:R, reducer:(accumulator:R, item:T) -> Task<R, E>):Future<StreamReduction<T, R, E>> {
		return each(item -> reducer(accumulator, item).map(result -> switch result {
			case Ok(value):
				accumulator = value;
				StreamMessage.Continue;
			case Error(error):
				StreamMessage.Error(error);
		})).map(result -> switch result {
			case Depleted: StreamReduction.Reduced(accumulator);
			case Paused(_): throw 'assert';
			case Clogged(error, next): StreamReduction.Clogged(error, next);
			case Errored(error): StreamReduction.Errored(error);
		});
	}

	public inline function collect() {
		return reduce([], (accumulator:Array<T>, value:T) -> {
			accumulator.push(value);
			accumulator;
		});
	}

	abstract public function next():Future<StreamStep<T, E>>;

	abstract public function each(handler:StreamHandler<T, E>):Future<StreamResult<T, E>>;
}

class LazyStream<T, E> extends StreamObject<T, E> {
	final stream:Future<Stream<T, E>>;

	public function new(stream) {
		this.stream = stream;
	}

	public function next():Future<StreamStep<T, E>> {
		return stream.flatMap(stream -> stream.next());
	}

	public function each(handler:StreamHandler<T, E>):Future<StreamResult<T, E>> {
		return stream.flatMap(stream -> stream.each(handler));
	}
}

class ValueStream<T, E> extends StreamObject<T, E> {
	final item:T;

	public function new(item) {
		this.item = item;
	}

	public function next():Future<StreamStep<T, E>> {
		return Future.immediate(StreamStep.Next(item, Stream.empty()));
	}

	public function each(handler:StreamHandler<T, E>):Future<StreamResult<T, E>> {
		return handler(item).map(result -> switch result {
			case Continue | Done: StreamResult.Depleted;
			case Pause: StreamResult.Paused(this);
			case Clog(error): StreamResult.Clogged(error, this);
			case Error(error): StreamResult.Errored(error);
		});
	}
}

class ErroredStream<T, E> extends StreamObject<T, E> {
	final error:E;

	public function new(error) {
		this.error = error;
	}

	public function next():Future<StreamStep<T, E>> {
		return Future.immediate(StreamStep.Error(error));
	}

	public function each(handler:StreamHandler<T, E>):Future<StreamResult<T, E>> {
		return Future.immediate(StreamResult.Errored(error));
	}
}

class EmptyStream<T, E> extends StreamObject<T, E> {
	public function new() {}

	override public function isDepleted() {
		return true;
	}

	public function next():Future<StreamStep<T, E>> {
		return Future.immediate(StreamStep.Done);
	}

	public function each(handler:StreamHandler<T, E>):Future<StreamResult<T, E>> {
		return Future.immediate(StreamResult.Depleted);
	}
}

class CompoundStream<T, E> extends StreamObject<T, E> {
	final streams:Array<Stream<T, E>>;

	public function new(streams) {
		this.streams = streams;
	}

	public function next():Future<StreamStep<T, E>> {
		if (streams.length == 0) return Future.immediate(StreamStep.Done);
		return streams[0].next().flatMap(step -> switch step {
			case Next(item, next):
				var parts = streams.copy();
				parts[0] = next;
				Future.immediate(Next(item, new CompoundStream(parts)));
			case Done if (streams.length > 0):
				streams[1].next();
			default: Future.immediate(step);
		});
	}

	public function each(handler:StreamHandler<T, E>):Future<StreamResult<T, E>> {
		return new Future(activate -> consume(streams, handler, activate));
	}

	function consume(streams:Array<Stream<T, E>>, handler:StreamHandler<T, E>, finish:(result:StreamResult<T, E>) -> Void) {
		if (streams.length == 0) return finish(Depleted);

		streams[0].each(handler).handle(result -> switch result {
			case Depleted:
				consume(streams.slice(1), handler, finish);
			case Paused(next):
				streams = streams.copy();
				streams[0] = next;
				finish(Paused(new CompoundStream(streams)));
			case Clogged(error, next):
				if (next.isDepleted()) {
					streams = streams.slice(1);
				} else {
					streams = streams.copy();
					streams[0] = next;
				}
				finish(Clogged(error, new CompoundStream(streams)));
			case Errored(error):
				finish(Errored(error));
		});
	}
}

class GeneratorStream<T, E> extends StreamObject<T, E> {
	final nextStep:Future<StreamStep<T, E>>;

	public function new(nextStep) {
		this.nextStep = nextStep;
	}

	public function next() {
		return nextStep;
	}

	public function each(handler:StreamHandler<T, E>):Future<StreamResult<T, E>> {
		return new Future<StreamResult<T, E>>(activate -> {
			next().handle(result -> switch result {
				case Next(item, next):
					handler(item).handle(message -> switch message {
						case Continue: next.each(handler).handle(activate);
						case Pause: activate(Paused(this));
						case Done: activate(Depleted);
						case Clog(error): activate(Clogged(error, this));
						case Error(error): activate(Errored(error));
					});
				case Error(error):
					activate(Errored(error));
				case Done:
					activate(Depleted);
			});
		});
	}
}
