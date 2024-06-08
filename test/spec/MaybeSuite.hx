package spec;

class MaybeSuite extends Suite {
	function execute() {
		describe('kit.Maybe', () -> {
			describe('.map', () -> {
				it('will transform some value', () -> {
					var maybe:Maybe<String> = Some('foo');
					maybe.map(value -> value + 'bar').unwrap().should().be('foobar');
				});
				it('will still be None if the original value is None', () -> {
					var maybe:Maybe<String> = None;
					maybe.map(value -> value + 'bar').should().be(None);
				});
			});
		});
	}
}
