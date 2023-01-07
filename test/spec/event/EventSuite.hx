package spec.event;

class EventSuite extends Suite {
	function test() {
		describe('kit.event.Event<String>', () -> {
			describe('When given a listener', () -> {
				it('will trigger it on dispatch', () -> {
					var event = new Event<String>();
					event.add(value -> value.should().be('foo'));
					event.dispatch('foo');
				});
			});
		});
	}
}
