package kit;

import haxe.Exception;
import kit.Result;
import kit.Lazy;
import kit.Cancellable;

abstract Task<T>(Future<Result<T>>) to Future<Result<T>> {
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

	#if js
	@:from public static function ofJsPromise<T>(promise:js.lib.Promise<T>):Task<T> {
		return new Task(new Future(activate -> {
			promise.then(value -> activate(Success(value))).catchError(e -> switch e is Exception {
				case false: activate(Failure(new Exception('Unknown error: ${Std.string(e)}')));
				case true: activate(Failure(e));
			});
		}));
	}
	#end

	@:from public static function ofResult<T>(result:Result<T>) {
		return new Task(new Future(activate -> activate(result)));
	}

	@:from public static function ofFutureResult<T>(future:Future<Result<T>>) {
		return new Task(future);
	}

	@:from public static function ofFuture<T>(future:Future<T>) {
		return new Task(future.map(value -> Success(value)));
	}

	@:from public static function ofException<T>(e:Exception):Task<T> {
		return new Task(new Future(activate -> activate(Failure(e))));
	}

	@:from public static function ofSync<T>(value:T) {
		return new Task(new Future(activate -> activate(Success(value))));
	}

	public inline function new(future) {
		this = future;
	}

	public inline function next<R>(handler:(value:T) -> Task<R>):Task<R> {
		return this.flatMap(result -> switch result {
			case Success(value): handler(value);
			case Failure(exception): Task.ofException(exception);
		});
	}

	public inline function recover(handler:(exception:Exception) -> Task<T>):Task<T> {
		return this.flatMap(result -> switch result {
			case Success(value): Task.ofResult(Success(value));
			case Failure(exception): handler(exception);
		});
	}

	public inline function or(value:Lazy<T>):Future<T> {
		return this.map(result -> result.or(value));
	}

	public inline function handle(handler:(result:Result<T>) -> Void):Cancellable {
		return this.handle(handler);
	}
}
