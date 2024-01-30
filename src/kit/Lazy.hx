package kit;

@:forward(get)
abstract Lazy<T>(LazyObject<T>) {
	@:from @:noUsing public inline static function ofFunction<T>(get:() -> T):Lazy<T> {
		return new Lazy(get);
	}

	@:from @:noUsing public inline static function ofValue<T>(value:T) {
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
	var value:Result<T, Nothing> = Error(Nothing);

	public function new(resolve) {
		this.resolve = resolve;
	}

	public function get():T {
		return switch value {
			case Ok(value):
				value;
			case Error(_):
				var resolved = resolve();
				value = Ok(resolved);
				resolved;
		}
	}
}
