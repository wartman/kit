package kit.async;

import haxe.Exception;
import kit.ds.Result;
import kit.core.Lazy;

/**
	Represents a value that may fail or succeed in the future.

	Kit's Tasks are more directly comparable to js promises, and 
	are designed to work well with them. If you're targeting js,
	you can easily cast promises to Tasks, meaning most async js apis
	should be usable with minimal fuss.  
**/
abstract Task<T>(Future<Result<T>>) to Future<Result<T>> {
	public static function sequence<T>(...tasks:Task<T>):Task<Array<T>> {
		return new Future(activate -> {
			var pending = tasks.toArray();
			var result:Array<T> = [];
			var failed:Bool = false;
			function poll(index:Int) {
				// @todo: we need a way to cancel callbacks.
				if (failed) return;
				if (index == pending.length) return activate(Success(result));
				pending[index].handle(r -> if (!failed) switch r {
					case Success(value):
						result[index] = value;
						poll(index + 1);
					case Failure(e):
						failed = true;
						activate(Failure(e));
				});
				poll(0);
			}
		});
	}

	public static function parallel<T>(...tasks:Task<T>):Task<Array<T>> {
		// @todo: Figure out a way to do parallel stuff.
		throw new haxe.exceptions.NotImplementedException('Still figuring this one out');
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
		return new Task(new Future(activate -> future.handle(value -> activate(Success(value)))));
	}

	@:from public static function ofException(e:Exception) {
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
			case Failure(exception): (exception : Task<R>);
		});
	}

	public inline function or(value:Lazy<T>):Future<T> {
		return this.map(result -> result.or(value));
	}

	public inline function handle(handler:(result:Result<T>) -> Void):Void {
		this.handle(handler);
	}

	@:noCompletion
	public inline function activateWithValue(value:T) {
		this.activate(Success(value));
	}

	@:noCompletion
	public inline function activateWithException(e:Exception) {
		this.activate(Failure(e));
	}
}
