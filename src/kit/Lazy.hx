package kit;

import kit.Maybe;

@:forward(get)
abstract Lazy<T>(LazyObject<T>) {
	@:from public inline static function ofFunction<T>(get:() -> T):Lazy<T> {
		return new Lazy(get);
	}

	@:from public inline static function ofValue<T>(value:T) {
		return new Lazy(() -> value);
	}

	public inline function new(get:() -> T) {
		this = new SimpleLazyObject(get);
	}
}

typedef LazyObject<T> = {
	public function get():T;
}

class SimpleLazyObject<T> {
	final resolve:() -> T;
	var value:Maybe<T> = None;

	public function new(resolve) {
		this.resolve = resolve;
	}

	public function get():T {
		return switch value {
			case Some(value):
				value;
			case None:
				value = Some(resolve());
				get();
		}
	}
}
