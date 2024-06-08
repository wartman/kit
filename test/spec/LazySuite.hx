package spec;

class LazySuite extends Suite {
	function execute() {
		describe('kit.Lazy', () -> {
			describe('Given a function', () -> {
				it('will resolve on a call to `get`', () -> {
					var foo:Lazy<String> = () -> 'foo';
					foo.get().should().be('foo');
				});

				it('will only evaluate its value once', () -> {
					var count = 1;
					var foo:Lazy<String> = () -> 'foo${count++}';
					foo.get().should().be('foo1');
					foo.get().should().be('foo1');
					foo.get().should().be('foo1');
				});
			});
		});
	}
}
