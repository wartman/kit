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
			Future.immediate(Nothing);
		});
	}

	@:test(expects = 3, timeout = 100)
	function willRunInParallel() {
		return Task.parallel(
			Task.ok('foo'),
			Task.ok('bar')
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
			Task.ok('foo'),
			Task.ok('bar')
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

	@:test(expects = 1)
	function alwaysWillBeCalledOnOk() {
		return Task.ok('Foo').always(() -> Assert.pass());
	}

	@:test(expects = 1)
	function alwaysWillBeCalledOnError() {
		return Task.error('Foo').always(() -> Assert.pass()).recover(_ -> Task.nothing());
	}

	// @todo: We need to test nesting tasks -- seems to run into issues sometimes?
}
