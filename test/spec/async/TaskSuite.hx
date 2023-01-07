package spec.async;

import haxe.Exception;

class TaskSuite extends Suite {
	function execute() {
		describe('Given a static vlaue', () -> {
			it('will be converted into a task', (spec:Spec) -> {
				spec.expect(1);
				var foo:Task<String> = 'foo';
				return foo.next(foo -> foo + 'bar').next(value -> {
					value.should().be('foobar');
					Empty;
				});
			});
			it('can fail if an exception is returned', (spec:Spec) -> {
				spec.expect(1);
				var foo:Task<String> = 'foo';
				return foo.next(foo -> new Exception('expected')).recover(e -> {
					e.message.should().be('expected');
					Task.ofSync('foo');
				});
			});
		});
	}
}
