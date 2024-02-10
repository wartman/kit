package kit;

// @todo: Handle pausing and resuming
enum Message<T, E = Error> {
	Next(value:T);
	Finish;
	Fail(error:E);
}

// @todo: Handle pausing and resuming
typedef Writeable<T, E = Error> = {
	public function write(item:T):Void;
	public function fail(error:E):Void;
	public function end():Void;
}

typedef Readable<T, E = Error> = {
	public function pipe(writeable:Writeable<T, E>):Void;
}

typedef Generator<T, E> = (yield:(message:Message<T, E>) -> Void) -> Void;

private enum StreamStatus<T, E> {
	Inactive(generator:Generator<T, E>);
	Pending;
	Streaming(item:T);
	Depleted;
	Failed(error:E);
}

@:forward
@:forward.new
abstract Stream<T, E = Error>(StreamObject<T, E>) from StreamObject<T, E> to Readable<T, E> {
	#if nodejs
	@:from public static function ofNodeReadable<T>(readable:js.node.stream.Readable.IReadable):Stream<T> {
		return new Stream(yield -> {
			readable.once('end', () -> yield(Finish));
			// readable.once('close', () -> yield(Pause));
			readable.once('error', (e:{code:String, message:String}) -> {
				yield(Fail(new Error(InternalError, '${e.code}: Stream failed with ${e.message}')));
			});
			readable.on('data', chunk -> yield(Next(chunk)));
		});
	}
	#end

	@:from public static function ofTask<T, E>(task:Task<T, E>) {
		return new Stream<T, E>(yield -> {
			task.handle(result -> switch result {
				case Ok(value):
					yield(Next(value));
					yield(Finish);
				case Error(error):
					yield(Fail(error));
			});
		});
	}
}

class StreamObject<T, E = Error> {
	final output:Array<Writeable<T, E>> = [];
	var status:StreamStatus<T, E>;

	public function new(generator:Generator<T, E>) {
		status = Inactive(generator);
	}

	public function handle(?handler:(result:Result<Nothing, E>) -> Void) {
		if (handler != null) {
			pipe({
				write: _ -> {},
				end: () -> handler(Ok(Nothing)),
				fail: e -> handler(Error(e))
			});
		}

		switch status {
			case Inactive(generator):
				status = Pending;
				generator(message -> switch status {
					case Inactive(_) | Pending | Streaming(_):
						switch message {
							case Next(item):
								status = Streaming(item);
								for (stream in output) stream.write(item);
							case Finish:
								status = Depleted;
								for (stream in output) stream.end();
							case Fail(error):
								for (stream in output) stream.fail(error);
							default:
						}
					case Depleted | Failed(_):
						throw "Attempted to push data to a depleted or failed stream";
				});
			default:
		}
	}

	public function pipe(writeable:Writeable<T, E>) {
		output.push(writeable);
		switch status {
			case Inactive(_) | Pending: // noop
			case Streaming(item): writeable.write(item);
			case Depleted: writeable.end();
			case Failed(error): writeable.fail(error);
		}
	}

	public function each(handler:(item:T) -> Void):Task<Nothing, E> {
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
