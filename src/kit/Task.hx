package kit;

import haxe.Exception;
import kit.Result;
import kit.Cancellable;
import kit.Nothing;

@:forward(map, flatMap)
abstract Task<T, E = Error>(Future<Result<T, E>>) from Future<Result<T, E>> to Future<Result<T, E>> {
	@:noUsing public static function nothing<E>():Task<Nothing, E> {
		return new Task(activate -> activate(Ok(Nothing)));
	}

	public static function inParallel<T, E>(?tasks:Array<Task<T, E>>):Task<Array<T>, E> {
		if (tasks == null || tasks.length == 0) return Task.ok([]);

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

	public static function inSequence<T, E>(?tasks:Array<Task<T, E>>):Task<Array<T>, E> {
		if (tasks == null || tasks.length == 0) return Task.ok([]);

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

	@:deprecated('Use inParallel instead')
	@:noUsing public inline extern static function parallel<T, E>(...tasks:Task<T, E>):Task<Array<T>, E> {
		return inParallel(tasks);
	}

	@:deprecated('use inSequence instead')
	@:noUsing public inline extern static function sequence<T, E>(...tasks:Task<T, E>):Task<Array<T>, E> {
		return inSequence(tasks);
	}

	@:from @:noUsing public static function ofResult<T, E>(result:Result<T, E>):Task<T, E> {
		return new Task(activate -> activate(result));
	}

	@:from @:noUsing public static function ofFuture<T, E>(future:Future<T>):Task<T, E> {
		return future.map(value -> Ok(value));
	}

	@:from @:noUsing public static function ofError<T>(error:Error):Task<T, Error> {
		return new Task(activate -> activate(Error(error)));
	}

	@:from @:noUsing public static function ok<T, E>(value:T):Task<T, E> {
		return new Task(activate -> activate(Ok(value)));
	}

	@:noUsing public static function error<T, E>(e:E):Task<T, E> {
		return new Task(activate -> activate(Error(e)));
	}

	@:deprecated('Use `Task.ok` instead')
	@:noUsing public static function resolve<T, E>(value:T):Task<T, E> {
		return ok(value);
	}

	@:deprecated('Use `Task.error` instead')
	@:noUsing public static function reject<T, E>(e:E):Task<T, E> {
		return error(e);
	}

	public inline function new(activator) {
		this = new Future(activator);
	}

	public inline function inspect(handler:(value:T) -> Void):Task<T, E> {
		return next(value -> {
			handler(value);
			value;
		});
	}

	public inline function inspectError(handler:(error:E) -> Void):Task<T, E> {
		return mapError(error -> {
			handler(error);
			error;
		});
	}

	public inline function always(handler:() -> Void):Task<T, E> {
		return this.flatMap(result -> {
			handler();
			Future.immediate(result);
		});
	}

	public inline function next<R>(handler:(value:T) -> Task<R, E>):Task<R, E> {
		return this.flatMap(result -> switch result {
			case Ok(value): handler(value);
			case Error(e): error(e);
		});
	}

	public inline function mapError<R>(handler:(error:E) -> R):Task<T, R> {
		return this.flatMap(result -> switch result {
			case Ok(value): ok(value);
			case Error(e): error(handler(e));
		});
	}

	public inline function or(value:Lazy<T>):Future<T> {
		return recover(_ -> Future.immediate(value.get()));
	}

	public inline function recover(handler:(error:E) -> Future<T>):Future<T> {
		return this.flatMap(result -> switch result {
			case Ok(value): Future.immediate(value);
			case Error(error): handler(error);
		});
	}

	public inline function handle(handler:(result:Result<T, E>) -> Void):Cancellable {
		return this.handle(handler);
	}

	public function eager():Task<T, E> {
		this.eager();
		return abstract;
	}

	@:to public inline function toFuture():Future<Result<T, E>> {
		return this;
	}

	@:to public inline function toDynamic():Task<Dynamic, E> {
		return this;
	}

	@:to public inline function toNothing():Task<Nothing, E> {
		return next(_ -> nothing());
	}

	#if js
	@:from @:noUsing public static function ofJsPromise<T>(promise:js.lib.Promise<T>):Task<T> {
		return new Task(activate -> {
			promise.then(value -> activate(Ok(value)), e -> switch e is Exception {
				case false: activate(Error(new Error(InternalError, 'Unknown error: ${Std.string(e)}')));
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
