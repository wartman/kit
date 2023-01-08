package kit.async;

import kit.core.Cancellable;
import haxe.Exception;

typedef FutureActivator<T> = (activate:(value:T) -> Void) -> Void;
typedef FutureHandler<T> = (value:T) -> Void;

private enum FutureState<T> {
	Inactive(activator:FutureActivator<T>, handlers:Array<FutureHandler<T>>);
	Suspended(handlers:Array<FutureHandler<T>>);
	Active(value:T);
}

class Future<T> {
	public inline static function immediate<T>(value:T) {
		return new Future(activate -> activate(value));
	}

	public static function parallel<T>(...futures:Future<T>):Future<Array<T>> {
		return new Future(activate -> {
			var result = [];
			var count = 0;
			for (index => future in futures) {
				future.handle(value -> {
					result[index] = value;
					count++;
					if (count == futures.length) activate(result);
				});
			}
		});
	}

	public static function sequence<T>(...futures:Future<T>):Future<Array<T>> {
		return new Future(activate -> {
			var result = [];
			function poll(index:Int) {
				if (index == futures.length) return activate(result);
				futures[index].handle(value -> {
					result[index] = value;
					poll(index + 1);
				});
			}
			poll(0);
		});
	}

	var state:FutureState<T>;

	public function new(activator) {
		state = Inactive(activator, []);
	}

	public function map<R>(transform:(value:T) -> R):Future<R> {
		return new Future(activate -> handle(value -> activate(transform(value))));
	}

	public function flatMap<R>(transform:(value:T) -> Future<R>):Future<R> {
		return new Future(activate -> handle(value -> transform(value).handle(activate)));
	}

	public function handle(handler:FutureHandler<T>):Cancellable {
		switch state {
			case Inactive(activator, handlers):
				state = Suspended(handlers.concat([handler]));
				activator(activate);
			case Suspended(handlers):
				handlers.push(handler);
			case Active(value):
				handler(value);
		}

		return () -> {
			switch state {
				case Inactive(_, handlers) | Suspended(handlers):
					handlers.remove(handler);
				default:
			}
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

	public function eager() {
		switch state {
			case Inactive(activator, handlers):
				state = Suspended(handlers);
				activator(activate);
			default:
		}
		return this;
	}

	function activate(value:T):Void {
		switch state {
			case Inactive(_, handlers) | Suspended(handlers):
				state = Active(value);
				for (handler in handlers) handler(value);
			case Active(_):
				throw new Exception('Attempted to activate a Future that was already activated');
		}
	}
}
