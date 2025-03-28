package kit;

using Kit;
using kit.Testing;

class TaskSuite extends Suite {
	@:test(expects = 1, timeout = 100)
	function convertsStaticValues() {
		var foo:Task<String> = 'foo';
		return foo.then(foo -> foo + 'bar').then(value -> {
			value.equals('foobar');
			value;
		});
	}

	@:test(expects = 1, timeout = 100)
	function willConvertErrorsToFailures() {
		var foo:Task<String> = 'foo';
		return foo.then(foo -> new Error(InternalError, 'expected')).recover(e -> {
			e.message.equals('expected');
			Future.immediate(Nothing);
		});
	}

	@:test(expects = 3, timeout = 100)
	function willRunInParallel() {
		return Task.inParallel([
			Task.ok('foo'),
			Task.ok('bar')
		]).then(values -> {
			values.length.equals(2);
			values.extract(try [foo, bar]);
			foo.equals('foo');
			bar.equals('bar');
			values;
		});
	}

	@:test(expects = 3, timeout = 100)
	function willRunInSequence() {
		return Task.inSequence([
			Task.ok('foo'),
			Task.ok('bar')
		]).then(values -> {
			values.length.equals(2);
			values.extract(try [foo, bar]);
			foo.equals('foo');
			bar.equals('bar');
			values;
		});
	}

	@:test(expects = 1)
	function ifNoTasksAreProvidedParallelWillStillActivate() {
		return Task.inParallel().then(values -> {
			values.length.equals(0);
			values;
		});
	}

	@:test(expects = 1)
	function ifNoTasksAreProvidedSequenceWillStillActivate() {
		return Task.inSequence().then(values -> {
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
		return Task.error('Foo').always(() -> Assert.pass()).recover(_ -> Future.immediate(Nothing));
	}

	// @todo: We need to test nesting tasks -- seems to run into issues sometimes?
}
