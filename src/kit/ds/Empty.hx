package kit.ds;

enum abstract Empty(Null<Dynamic>) {
	@:from static inline function ofAny<T>(t:Null<T>):Empty {
		return Empty;
	}

	final Empty = null;
}
