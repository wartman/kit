package kit;

import haxe.Exception;
import kit.Result;
import kit.Cancellable;
import kit.Nothing;

@:forward(map, flatMap)
abstract Task<T>(Future<Product<T>>) from Future<Product<T>> to Future<Product<T>> {
	public static function nothing():Task<Nothing> {
		return new Task(activate -> activate(Ok(Nothing)));
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
					case Ok(value):
						result[index] = value;
						count++;
						if (count >= tasks.length) activate(Ok(result));
					case Error(exception):
						failed = true;
						for (link in links) if (!link.isCanceled()) link.cancel();
						links = [];
						activate(Error(exception));
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
				if (index == tasks.length) return activate(Ok(result));
				tasks[index].handle(r -> if (!failed) switch r {
					case Ok(value):
						result[index] = value;
						poll(index + 1);
					case Error(e):
						failed = true;
						activate(Error(e));
				});
			}

			poll(0);
		});
	}

	@:from public static function ofProduct<T>(result:Product<T>) {
		return new Task(activate -> activate(result));
	}

	@:from public static function ofFuture<T>(future:Future<T>):Task<T> {
		return future.map(value -> Ok(value));
	}

	@:from public static function ofFailure<T>(failure:Failure):Task<T> {
		return new Task(activate -> activate(Error(failure)));
	}

	@:from public static function resolve<T>(value:T) {
		return new Task(activate -> activate(Ok(value)));
	}

	@:from public static function reject(e) {
		return new Task(activate -> activate(Error(e)));
	}

	public inline function new(activator) {
		this = new Future(activator);
	}

	public inline function next<R>(handler:(value:T) -> Task<R>):Task<R> {
		return this.flatMap(result -> switch result {
			case Ok(value): handler(value);
			case Error(error): Task.ofFailure(error);
		});
	}

	public inline function recover(handler:(failure:Failure) -> Future<T>):Future<T> {
		return this.flatMap(result -> switch result {
			case Ok(value): Future.immediate(value);
			case Error(failure): handler(failure);
		});
	}

	public inline function handle(handler:(result:Product<T>) -> Void):Cancellable {
		return this.handle(handler);
	}

	@:to public inline function toFuture():Future<Product<T>> {
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
			promise.then(value -> activate(Ok(value)), e -> switch e is Exception {
				case false: activate(Error(new Failure(InternalError, 'Unknown error: ${Std.string(e)}')));
				case true: activate(Error(e));
			});
		});
	}

	@:to public function toJsPromise():js.lib.Promise<T> {
		return new js.lib.Promise((res, rej) -> handle(result -> switch result {
			case Ok(value): res(value);
			case Error(error): rej(error);
		}));
	}
	#end
}
