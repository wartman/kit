package spec;

class TaskSuite extends Suite {
	function execute() {
		describe('kit.Task', () -> {
			describe('Given a static value', () -> {
				it('will be converted into a task', (spec:Spec) -> {
					spec.expect(1);
					var foo:Task<String> = 'foo';
					return foo.next(foo -> foo + 'bar').next(value -> {
						value.should().be('foobar');
						Maybe.None;
					});
				});

				it('can fail if an exception is returned', (spec:Spec) -> {
					spec.expect(1);
					var foo:Task<String> = 'foo';
					return foo.next(foo -> new Error(InternalError, 'expected')).recover(e -> {
						e.message.should().be('expected');
						Task.resolve('foo');
					});
				});
			});
		});
	}
}
