package kit;

enum StreamResult<T, E> {
	Streaming(data:T, next:Stream<T, E>);
	Paused(next:Stream<T, E>);
	// @todo: add clogged?
	Depleted;
	Errored(error:E);
}

typedef StreamHandler<T> = (value:T) -> Void;

@:forward
abstract Stream<T, E = Error>(StreamObject<T, E>) from StreamObject<T, E> {
	@:noUsing
	public static function value<T, E>(value:T):Stream<T, E> {
		return new ValueStream(value);
	}

	@:noUsing
	public static function event<T, E>(?event:Event<Yield<T, E>>):Stream<T, E> {
		return new EventStream(event ?? new Event<Yield<T, E>>());
	}

	@:noUsing
	public static function empty<T, E>():Stream<T, E> {
		return new EmptyStream();
	}

	@:noUsing
	public static function generator<T, E>(handler:Future.FutureActivator<StreamResult<T, E>>):Stream<T, E> {
		return new GeneratorStream(new Future(handler));
	}

	#if nodejs
	@:noUsing
	public static function ofNodeReadable<T>(readable:js.node.stream.Readable.IReadable, ?parse:(data:Dynamic) -> T):Stream<T, Error> {
		var event = new Event<Yield<T, Error>>();
		var stream = Stream.event(event);

		readable.once('end', () -> event.dispatch(End));
		readable.once('error', (e:{code:String, message:String}) -> {
			event.dispatch(Error(new Error(InternalError, '${e.code}: Stream failed with ${e.message}')));
		});

		if (parse == null) {
			readable.on('data', data -> event.dispatch(Data(data)));
		} else {
			readable.on('data', data -> event.dispatch(Data(parse(data))));
		}

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
		function next(step:(step:StreamResult<T, E>) -> Void) {
			step(if (iterator.hasNext()) {
				Streaming(iterator.next(), generator(next));
			} else {
				Depleted;
			});
		}
		return generator(next);
	}

	@:from
	@:noUsing
	public static function ofTask<T, E>(task:Task<T, E>):Stream<T, E> {
		return generator(yield -> {
			task.handle(result -> switch result {
				case Ok(value): yield(Streaming(value, empty()));
				case Error(error): yield(Errored(error));
			});
		});
	}
}

abstract class StreamObject<T, E> {
	public var depleted(get, never):Bool;

	function get_depleted() {
		return false;
	}

	public function prepend(other:Stream<T, E>):Stream<T, E> {
		if (depleted) return other;
		return new CompoundStream([other, this]);
	}

	public function append(other:Stream<T, E>):Stream<T, E> {
		if (depleted) return other;
		return new CompoundStream([this, other]);
	}

	public function map<R>(transform:(value:T) -> Task<R, E>):Stream<R, E> {
		return new TransformStream(this, transform);
	}

	public function reduce<R>(accumulator:R, reducer:(accumulator:R, item:T) -> R):Task<R, E> {
		return new Task(activate -> {
			each(item -> accumulator = reducer(accumulator, item)).handle(result -> switch result {
				case Streaming(data, next):
					next.reduce(reducer(accumulator, data), reducer).handle(activate);
				case Paused(_):
					throw 'assert';
				case Depleted:
					activate(Ok(accumulator));
				case Errored(error):
					activate(Error(error));
			});
		});
	}

	public function collect() {
		return reduce([], (accumulator, item) -> accumulator.concat([item]));
	}

	abstract public function next():Future<StreamResult<T, E>>;

	abstract public function each(handler:StreamHandler<T>):Future<StreamResult<T, E>>;
}

enum Yield<T, E> {
	Data(value:T);
	End;
	Error(error:E);
}

class EventStream<T, E> extends StreamObject<T, E> {
	final event:Event<Yield<T, E>>;
	final stream:GeneratorStream<T, E>;

	var openStreams:Int = 0;

	public function new(event) {
		this.event = event;
		this.stream = new GeneratorStream(new Future(activate -> {
			event.addOnce(yield -> switch yield {
				case Data(value): activate(Streaming(value, new EventStream(event)));
				case Error(error): activate(Errored(error));
				case End: activate(Depleted);
			});
		}).eager());
	}

	public function next():Future<StreamResult<T, E>> {
		return stream.next();
	}

	public function each(handler:StreamHandler<T>):Future<StreamResult<T, E>> {
		return stream.each(handler);
	}
}

class EmptyStream<T, E> extends StreamObject<T, E> {
	public function new() {}

	public function next():Future<StreamResult<T, E>> {
		return Future.immediate(Depleted);
	}

	public function each(handler:StreamHandler<T>):Future<StreamResult<T, E>> {
		return Future.immediate(Depleted);
	}
}

class ErrorStream<T, E> extends StreamObject<T, E> {
	final error:E;

	public function new(error) {
		this.error = error;
	}

	public function next():Future<StreamResult<T, E>> {
		return Future.immediate(Errored(error));
	}

	public function each(handler:StreamHandler<T>):Future<StreamResult<T, E>> {
		return Future.immediate(Errored(error));
	}
}

class ValueStream<T, E> extends StreamObject<T, E> {
	final value:T;

	public function new(value) {
		this.value = value;
	}

	public function next():Future<StreamResult<T, E>> {
		return Future.immediate(Streaming(value, new EmptyStream()));
	}

	public function each(handler:StreamHandler<T>):Future<StreamResult<T, E>> {
		handler(value);
		return Future.immediate(Depleted);
	}
}

class CompoundStream<T, E> extends StreamObject<T, E> {
	final sources:Array<Stream<T, E>>;

	override function get_depleted():Bool {
		return sources.length == 0;
	}

	public function new(sources) {
		this.sources = sources;
	}

	public function next():Future<StreamResult<T, E>> {
		if (sources.length == 0) return Future.immediate(Depleted);

		return sources[0].next().flatMap(result -> switch result {
			case Streaming(data, next):
				var nextSources = sources.copy();
				nextSources[0] = next;
				Future.immediate(Streaming(data, new CompoundStream(nextSources)));
			case Depleted if (sources.length > 0):
				sources[1].next();
			default:
				Future.immediate(result);
		});
	}

	public function each(handler:StreamHandler<T>):Future<StreamResult<T, E>> {
		if (sources.length == 0) return Future.immediate(Depleted);

		return sources[0].each(handler).flatMap(result -> switch result {
			case Streaming(data, next):
				var nextParts = sources.copy();
				nextParts[0] = next;
				Future.immediate(Streaming(data, new CompoundStream(nextParts)));
			case Depleted if (sources.length > 0):
				sources[1].each(handler);
			default:
				Future.immediate(result);
		});
	}
}

class TransformStream<T, R, E> extends StreamObject<R, E> {
	final source:Stream<T, E>;
	final transform:(value:T) -> Task<R, E>;

	public function new(source, transform) {
		this.transform = transform;
		this.source = source;
	}

	public function next():Future<StreamResult<R, E>> {
		return source.next().flatMap(result -> switch result {
			case Streaming(data, next):
				return transform(data).flatMap(result -> switch result {
					case Ok(data):
						Future.immediate(Streaming(data, new TransformStream(next, transform)));
					case Error(error):
						Future.immediate(Errored(error));
				});
			case Paused(next):
				Future.immediate(Paused(new TransformStream(next, transform)));
			case Depleted:
				Future.immediate(Depleted);
			case Errored(error):
				Future.immediate(Errored(error));
		});
	}

	public function each(handler:StreamHandler<R>):Future<StreamResult<R, E>> {
		return new Future(activate -> {
			next().handle(result -> switch result {
				case Streaming(data, next):
					handler(data);
					next.each(handler).handle(activate);
				default:
					activate(result);
			});
		});
	}
}

class GeneratorStream<T, E> extends StreamObject<T, E> {
	final step:Future<StreamResult<T, E>>;

	public function new(step) {
		this.step = step;
	}

	public function next():Future<StreamResult<T, E>> {
		return step;
	}

	public function each(handler:StreamHandler<T>):Future<StreamResult<T, E>> {
		return new Future(activate -> {
			step.handle(result -> switch result {
				case Streaming(data, next):
					handler(data);
					next.each(handler).handle(activate);
				default:
					activate(result);
			});
		});
	}
}
