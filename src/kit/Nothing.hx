package kit;

enum abstract Nothing(Int) {
	final Nothing = 0;

	@:from public inline static function fromDynamic<T:Dynamic>(value:T):Nothing {
		return Nothing;
	}
}
