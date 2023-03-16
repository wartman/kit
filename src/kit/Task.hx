package kit;

import haxe.Exception;
import kit.Result;
import kit.Cancellable;
import kit.Nothing;

@:forward(map, flatMap)
abstract Task<T>(Future<Result<T>>) from Future<Result<T>> to Future<Result<T>> {
	public static function nothing():Task<Nothing> {
		return new Task(activate -> activate(Success(Nothing)));
	}

	public static function parallel<T>(...tasks:Task<T>):Task<Array<T>> {
		return new Future(activate -> {
			var failed:Bool = false;
			var result:Array<T> = [];
			var count:Int = 0;
			var links:Array<Cancellable> = [];

			for (index => task in tasks) {
				if (failed) break;
				var link = task.handle(r -> if (!failed) switch r {
					case Success(value):
						result[index] = value;
						count++;
						if (count >= tasks.length) activate(Success(result));
					case Failure(exception):
						failed = true;
						for (link in links) if (!link.isCanceled()) link.cancel();
						links = [];
						activate(Failure(exception));
				});
				links.push(link);
			}
		});
	}

	public static function sequence<T>(...tasks:Task<T>):Task<Array<T>> {
		return new Future(activate -> {
			var result:Array<T> = [];
			var failed:Bool = false;

			function poll(index:Int) {
				if (failed) return;
				if (index == tasks.length) return activate(Success(result));
				tasks[index].handle(r -> if (!failed) switch r {
					case Success(value):
						result[index] = value;
						poll(index + 1);
					case Failure(e):
						failed = true;
						activate(Failure(e));
				});
			}

			poll(0);
		});
	}

	@:from public static function ofResult<T>(result:Result<T>) {
		return new Task(activate -> activate(result));
	}

	@:from public static function ofFuture<T>(future:Future<T>):Task<T> {
		return future.map(value -> Success(value));
	}

	@:from public static function ofException<T, E:Exception>(e:E):Task<T> {
		return new Task(activate -> activate(Failure(e)));
	}

	@:from public static function resolve<T>(value:T) {
		return new Task(activate -> activate(Success(value)));
	}

	@:from public static function reject(e) {
		return new Task(activate -> activate(Failure(e)));
	}

	public inline function new(activator) {
		this = new Future(activator);
	}

	public inline function next<R>(handler:(value:T) -> Task<R>):Task<R> {
		return this.flatMap(result -> switch result {
			case Success(value): handler(value);
			case Failure(exception): Task.ofException(exception);
		});
	}

	public inline function recover(handler:(exception:Exception) -> Future<T>):Future<T> {
		return this.flatMap(result -> switch result {
			case Success(value): Future.immediate(value);
			case Failure(exception): handler(exception);
		});
	}

	public inline function handle(handler:(result:Result<T>) -> Void):Cancellable {
		return this.handle(handler);
	}

	@:to public inline function toFuture():Future<Result<T>> {
		return this;
	}

	@:to public inline function toDynamic():Task<Dynamic> {
		return this;
	}

	@:to public inline function toNothing():Task<Nothing> {
		return next(_ -> Nothing);
	}

	#if js
	@:from public static function ofJsPromise<T>(promise:js.lib.Promise<T>):Task<T> {
		return new Task(activate -> {
			promise.then(value -> activate(Success(value))).catchError(e -> switch e is Exception {
				case false: activate(Failure(new Exception('Unknown error: ${Std.string(e)}')));
				case true: activate(Failure(e));
			});
		});
	}

	@:to public function toJsPromise():js.lib.Promise<T> {
		return new js.lib.Promise((res, rej) -> handle(result -> switch result {
			case Success(value): res(value);
			case Failure(error): rej(error);
		}));
	}
	#end
}
