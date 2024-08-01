package kit;

using kit.Testing;

class MaybeSuite extends Suite {
	@:test
	function willTransformSomeValue() {
		var maybe:Maybe<String> = Some('foo');
		maybe.map(value -> value + 'bar').unwrap().equals('foobar');
	}

	@:test
	function willStillBeNoneIfTheOriginalValueWasNone() {
		var maybe:Maybe<String> = None;
		maybe.map(value -> value + 'bar').equals(None);
	}
}
