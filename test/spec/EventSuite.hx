package spec;

class EventSuite extends Suite {
	function execute() {
		describe('kit.Event<String>', () -> {
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
