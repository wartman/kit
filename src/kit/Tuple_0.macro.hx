package kit;

/**
	This file is a bit weird, but it allows us to use the `Tuple.of(...)` macro.
	Hopefully I'll come up with a better way to do this, as this feels...bad.
**/
abstract Tuple_0({}) {
	public static function of(...exprs) {
		return kit.internal.TupleBuilder.fromExprs(...exprs);
	}
}
