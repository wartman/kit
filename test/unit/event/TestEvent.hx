package unit.event;

import kit.event.Event;

using Medic;

class TestEvent implements TestCase {
	public function new() {}

	@:test('Events work')
	function testSimple() {
		var event = new Event<String>();
		event.add(value -> value.equals('foo'));
		event.dispatch('foo');
	}
}
