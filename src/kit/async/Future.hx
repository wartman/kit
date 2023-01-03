package kit.async;

import haxe.Exception;

private enum FutureState<T> {
	Suspended(handlers:Array< (value:T) -> Void>);
	Active(value:T);
}

/**
	Represents a value that should become available in the future. There is 
	no guarantee when (or even if) the Future will activate, and it
	may be immediate. Use a `haxe.Timer.delay(...)` if you need to be sure 
	activation will happen later (or some other similar mechanism).

	Futures, unlike js promises, will *not* catch exceptions or otherwise
	allow you to recover from an error. This is intentional -- Futures are
	designed to be minimal and easy to understand, with more complex behavior
	built on top of them. Use a `kit.async.Task` if you want error handling.
**/
class Future<T> {
	public inline static function immediate<T>(value:T) {
		return new Future(activate -> activate(value));
	}

	public static function sequence<T>(...futures:Future<T>):Future<Array<T>> {
		return new Future(activate -> {
			var pending = futures.toArray();
			var result = [];
			function poll(index:Int) {
				if (index == pending.length) return activate(result);
				pending[index].handle(value -> {
					result[index] = value;
					poll(index + 1);
				});
			}
			poll(0);
		});
	}

	public static function parallel<T>(...futures:Future<T>):Future<Array<T>> {
		// @todo: Figure out a way to do parallel stuff.
		throw new haxe.exceptions.NotImplementedException('Still figuring this one out');
	}

	var state:FutureState<T> = Suspended([]);

	public function new(?activator:(activate:(value:T) -> Void) -> Void) {
		if (activator != null) activator(activate);
	}

	public function map<R>(transform:(value:T) -> R):Future<R> {
		return switch state {
			case Suspended(handlers):
				var future:Future<R> = new Future();
				var activator = (value:T) -> future.activate(transform(value));
				state = Suspended(handlers.concat([activator]));
				future;
			case Active(value):
				new Future(activate -> activate(transform(value)));
		}
	}

	public function flatMap<R>(transform:(value:T) -> Future<R>):Future<R> {
		return new Future(activate -> handle(value -> transform(value).handle(activate)));
	}

	public function handle(handler:(value:T) -> Void):Void {
		switch state {
			case Suspended(handlers):
				state = Suspended(handlers.concat([handler]));
			case Active(value):
				handler(value);
		}
	}

	public function merge<B, R>(other:Future<B>, combine:(a:T, b:B) -> R):Future<R> {
		return switch [state, other.state] {
			case [Active(a), Active(b)]:
				new Future(activate -> activate(combine(a, b)));
			default:
				new Future(activate -> {
					function poll() switch [state, other.state] {
						case [Active(a), Active(b)]:
							activate(combine(a, b));
						default:
					}
					handle(_ -> poll());
					other.handle(_ -> poll());
				});
		}
	}

	/**
		Activate a Suspended future. 

		Note that Futures may only be activated once. Calling `activate` on an 
		active Future will throw an exception.

		Using this method is discouraged unless you absolutely need it. You should
		prefer activating futures from the constructor's callback whenever 
		possible (e.g. `new Future<Bool>(activate -> activate(true)))`.
	**/
	public function activate(value:T):Void {
		switch state {
			case Suspended(handlers):
				state = Active(value);
				for (handler in handlers) handler(value);
			case Active(_):
				throw new Exception('Attempted to activate a Future that was already activated');
		}
	}
}
