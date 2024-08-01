package kit;

using kit.Testing;

class TaskSuite extends Suite {
	@:test(expects = 1)
	function convertsStaticValues() {
		var foo:Task<String> = 'foo';
		return foo.next(foo -> foo + 'bar').next(value -> {
			value.equals('foobar');
			value;
		});
	}

	@:test(expects = 1)
	function willConvertExceptionsToFailures() {
		var foo:Task<String> = 'foo';
		return foo.next(foo -> new Error(InternalError, 'expected')).recover(e -> {
			e.message.equals('expected');
			Task.resolve('foo');
		});
	}
}
