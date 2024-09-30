package kit;

using Kit;
using kit.Testing;

class TaskSuite extends Suite {
	@:test(expects = 1, timeout = 100)
	function convertsStaticValues() {
		var foo:Task<String> = 'foo';
		return foo.next(foo -> foo + 'bar').next(value -> {
			value.equals('foobar');
			value;
		});
	}

	@:test(expects = 1, timeout = 100)
	function willConvertErrorsToFailures() {
		var foo:Task<String> = 'foo';
		return foo.next(foo -> new Error(InternalError, 'expected')).recover(e -> {
			e.message.equals('expected');
			Task.resolve('foo');
		});
	}

	@:test(expects = 3, timeout = 100)
	function willRunInParallel() {
		return Task.parallel(
			Task.resolve('foo'),
			Task.resolve('bar')
		).next(values -> {
			values.length.equals(2);
			values.extract(try [foo, bar]);
			foo.equals('foo');
			bar.equals('bar');
			values;
		});
	}

	@:test(expects = 3, timeout = 100)
	function willRunInSequence() {
		return Task.sequence(
			Task.resolve('foo'),
			Task.resolve('bar')
		).next(values -> {
			values.length.equals(2);
			values.extract(try [foo, bar]);
			foo.equals('foo');
			bar.equals('bar');
			values;
		});
	}

	@:test(expects = 1)
	function ifNoTasksAreProvidedParallelWillStillActivate() {
		return Task.parallel().next(values -> {
			values.length.equals(0);
			values;
		});
	}

	@:test(expects = 1)
	function ifNoTasksAreProvidedSequenceWillStillActivate() {
		return Task.sequence().next(values -> {
			values.length.equals(0);
			values;
		});
	}

	// @todo: We need to test nesting tasks -- seems to run into issues sometimes?
}
