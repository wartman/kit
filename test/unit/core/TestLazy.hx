package unit.core;

import kit.core.Lazy;

using Medic;

class TestLazy implements TestCase {
	public function new() {}

	@:test('Lazy only evaluates its value once')
	function testSimple() {
		var num = 1;
		var lazy = new Lazy(() -> num += 1);
		num.equals(1);
		lazy.get().equals(2);
		lazy.get().equals(2);
		num.equals(2);
	}
}
