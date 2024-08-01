package kit;

using kit.Testing;

class EventSuite extends Suite {
	@:test(expects = 1)
	public function dispatchingWorks() {
		var event = new Event<String>();
		event.add(value -> value.equals('foo'));
		event.dispatch('foo');
	}
}
