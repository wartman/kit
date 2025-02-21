package kit;

using kit.Testing;
using kit.Sugar;

class TupleTest extends Suite {
	@:test(expects = 4)
	function tuplesWork() {
		var none = new Tuple();
		none.notEquals(null);

		var one = new Tuple<Int>(1);
		one._0.equals(1);

		// Just to make sure that the Tuple in Kit.hx works:
		var two = new Kit.Tuple<Int, String>(1, 'foo');
		two._0.equals(1);
		two._1.equals('foo');
	}

	@:test(expects = 3)
	function tupleOfMethodWorks() {
		var tupleOfMixedTypes = Tuple.of(1, true, 'foo');
		tupleOfMixedTypes.extract(try {_0: one, _1: two, _2: three});
		one.equals(1);
		two.equals(true);
		three.equals('foo');
	}
}
