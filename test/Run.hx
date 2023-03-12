import haxe.Exception;
import kit.Assert;
import Helpers;

using Kit;

#if !debug
#error "-D debug must be set for testing to work"
#end
#if macro
#error 'Cannot be run in macro context'
#end
// Note: these tests intentionally only require Kit's builtin assert
// function. We may move to something more robust later, but I want
// no dependencies in the core Kit package if possible.
function main() {
	print('Starting tests...');

	testResult();
	testFuture();
	testExtractSugar();
	testPipeSugar();
	testEvent();
	testLazy();
}

private function testResult() {
	var result:Result<String> = Success('Ok');
	result.map(value -> value + ' Ok').extract(Success(var value = 'Failed'));
	assert(value == 'Ok Ok');

	var result:Result<String> = Failure(new Exception('Failed'));
	result.map(value -> value + ' Ok').extract(Failure(var exception));
	assert(exception.message == 'Failed');
}

// @todo: This test should return async.
private function testFuture() {
	var future = new Future(activate -> activate('pass'));
	future.handle(value -> assert(value == 'pass'));

	var foo = new Future(activate -> activate('foo'));
	foo.map(foo -> foo + 'bar').map(bar -> bar + 'bin').handle(value -> assert(value == 'foobarbin'));

	var called = 0;
	Future.sequence(new Future(activate -> {
		assert(called == 0);
		called++;
		activate('foo');
	}), new Future(activate -> {
		assert(called == 1);
		called++;
		activate('bar');
	})).handle(values -> {
		values.extract([var foo, var bar]);
		assert(called == 2);
		assert(foo == 'foo');
		assert(bar == 'bar');
	});

	Future.parallel(new Future(activate -> activate('foo')), new Future(activate -> activate('bar'))).handle(values -> {
		values.extract([var foo, var bar]);
		assert(foo == 'foo');
		assert(bar == 'bar');
	});

	var future = new Future(activate -> activate('string'));
	var link = future.handle(value -> Empty);
	assert(link is CancellableLink);
}

private function testExtractSugar() {
	var foo:{a:String, b:Int} = {a: 'a', b: 1};
	foo.extract({a: var a, b:var b});
	assert(a == 'a');
	assert(b == 1);

	var foo:Maybe<String> = Some('foo');
	foo.extract(Some(var actual));
	assert(actual == 'foo');

	var foo:Maybe<String> = None;
	foo.extract(Some(var actual = 'foo'));
	assert(actual == 'foo');

	var foo:Maybe<String> = Some('foo');
	foo.ifExtract(Some(var value), assert(value == 'foo'));

	var foo:Maybe<String> = None;
	foo.ifExtract(Some(var value), {
		assert(value == 'foo');
	}, {
		assert(foo == None);
	});

	// Make sure nothing leaks into the parent scope:
	var foo:Maybe<String> = Some('foo');
	var value:String = 'bar';
	foo.ifExtract(Some(var value), assert(value == 'foo'));
	assert(value == 'bar');
}

private function testPipeSugar() {
	function add(input:String, append:String) return input + append;

	var result = 'foo'.pipe(add(_, 'bar'), add('bin', _), add(_, 'bax'));
	assert(result == 'binfoobarbax');

	// Can use lambdas/functions with a single arg:
	var result = 'foo'.pipe(add(_, 'bar'), str -> str + 'ok', add('ok', _));
	assert(result == 'okfoobarok');
}

private function testEvent() {
	var event = new Event<String>();
	var count = 0;
	event.add(value -> {
		count++;
		assert(value == 'foo');
	});
	event.dispatch('foo');
	assert(count == 1);
}

private function testLazy() {
	var foo:Lazy<String> = () -> 'foo';
	assert(foo.get() == 'foo');

	var count = 1;
	var foo:Lazy<String> = () -> 'foo${count++}';
	assert(foo.get() == 'foo1');
	assert(foo.get() == 'foo1');
	assert(foo.get() == 'foo1');
}
