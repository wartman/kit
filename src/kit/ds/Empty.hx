package kit.ds;

/**
	Indicates the lack of a value (like a unit-type).
**/
enum abstract Empty(Null<Dynamic>) {
	@:from static inline function ofAny<T>(t:Null<T>):Empty {
		return Empty;
	}

	final Empty = null;
}
