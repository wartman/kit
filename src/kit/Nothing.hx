package kit;

enum abstract Nothing(Int) {
	final Nothing = 0;

	@:noUsing
	@:from public inline static function fromDynamic<T:Dynamic>(value:T):Nothing {
		return Nothing;
	}
}
