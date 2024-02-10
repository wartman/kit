package kit;

enum Message<T, E = Error> {
	Next(value:T);
	Finish;
	Fail(error:E);
}

typedef Writeable<T, E = Error> = {
	public function write(item:T):Void;
	public function fail(error:E):Void;
	public function end():Void;
}

typedef Readable<T, E = Error> = {
	public function pipe(writeable:Writeable<T, E>):Void;
}

private enum StreamStatus<T, E> {
	Empty;
	Depleted;
	Streaming(item:T);
	Failed(error:E);
}

@:forward
@:forward.new
abstract Stream<T, E = Error>(StreamObject<T, E>) to Writeable<T, E> to Readable<T, E> {
	#if nodejs
	@:from public static function ofNodeReadable<T>(readable:js.node.stream.Readable.IReadable):Stream<T> {
		var stream = new Stream();

		readable.once('end', () -> stream.end());
		readable.once('close', () -> stream.end());
		readable.once('error', (e:{code:String, message:String}) -> {
			stream.fail(new Error(InternalError, '${e.code}: Stream failed with ${e.message}'));
		});
		readable.on('data', chunk -> stream.write(cast chunk));

		return stream;
	}
	#end

	@:from public static function ofTask<T, E>(task:Task<T, E>) {
		var stream = new Stream<T, E>();
		task.handle(result -> switch result {
			case Ok(value):
				stream.write(value);
				stream.end();
			case Error(error):
				stream.fail(error);
		});
		return stream;
	}

	public inline static function generate<T, E>(generator) {
		return new Generator<T, E>(generator);
	}
}

class Generator<T, E = Error> extends StreamObject<T, E> {
	final generator:(yield:(message:Message<T, E>) -> Void) -> Void;

	public function new(generator) {
		super();
		this.generator = generator;
	}

	public function start() {
		generator(send);
	}
}

class StreamObject<T, E = Error> {
	final output:Array<Writeable<T, E>> = [];
	var status:StreamStatus<T, E> = Empty;

	public function new() {}

	public function send(message:Message<T, E>) {
		switch message {
			case Next(value): write(value);
			case Finish: end();
			case Fail(error): fail(error);
		}
	}

	public function pipe(writeable:Writeable<T, E>) {
		output.push(writeable);
		switch status {
			case Empty: // noop
			case Streaming(item): writeable.write(item);
			case Depleted: writeable.end();
			case Failed(error): writeable.fail(error);
		}
	}

	public function write(item:T) {
		switch status {
			case Empty | Streaming(_):
				status = Streaming(item);
				for (writeable in output) writeable.write(item);
			case Depleted: // throw an error?
			case Failed(_): // noop?
		}
	}

	public function fail(error:E) {
		status = Failed(error);
		for (writeable in output) {
			writeable.fail(error);
		}
	}

	public inline function each(handler:(item:T) -> Void):Task<Nothing, E> {
		return new Task<Nothing, E>(activate -> pipe({
			write: handler,
			fail: e -> activate(Error(e)),
			end: () -> activate(Ok(Nothing))
		})).eager();
	}

	public function end() {
		status = Depleted;
		for (writeable in output) {
			writeable.end();
		}
	}
}
