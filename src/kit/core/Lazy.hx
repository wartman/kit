package kit.core;

import kit.ds.Option;

/**
	A value that is lazily resolved once.
**/
@:forward(get)
abstract Lazy<T>(LazyObject<T>) {
	@:from public inline static function ofFunction<T>(get:() -> T) {
		return new Lazy(new SimpleLazyObject(get));
	}

	@:from public inline static function ofValue<T>(value:T) {
		return new Lazy({get: () -> value});
	}

	public inline function new(lazy) {
		this = lazy;
	}
}

typedef LazyObject<T> = {
	public function get():T;
}

class SimpleLazyObject<T> {
	final resolve:() -> T;
	var value:Option<T> = None;

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
