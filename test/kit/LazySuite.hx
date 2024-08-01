package kit;

using kit.Testing;

class LazySuite extends Suite {
	@:test(expects = 1)
	function testGet() {
		var foo:Lazy<String> = () -> 'foo';
		foo.get().equals('foo');
	}

	@:test(expects = 3)
	function onlyEvaluatesOnce() {
		var count = 1;
		var foo:Lazy<String> = () -> 'foo${count++}';
		foo.get().equals('foo1');
		foo.get().equals('foo1');
		foo.get().equals('foo1');
	}
}
