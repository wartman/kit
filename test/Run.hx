import kit.Assert;

using Helpers;
using Kit;

#if !debug
#error "-D debug must be set for testing to work"
#end
// Note: these tests intentionally only require Kit's builtin assert
// function. We may move to something more robust later, but I want
// no dependencies in the core Kit package if possible.
function main() {
	'Starting tests...'.print();

	// @todo: These should all be async?
	testResult();
	testGetResult();
	testMaybe();
	testFuture();
	testTask();
	testNothing();
	testExtractSugar();
	testPipeSugar();
	testNullSugar();
	testEvent();
	testLazy();
	testStream();
}

private function testResult() {
	var result:Result<String, String> = Ok('Ok');
	result.map(value -> value + ' Ok').extract(Ok(value = 'Failed'));
	assert(value == 'Ok Ok');
	assert(result.isOk());

	var result:Result<String, String> = Error('Failed');
	result.map(value -> value + ' Ok').extract(Error(message));
	assert(message == 'Failed');
	assert(result.isError());
}

private function testGetResult() {
	function foo():String {
		throw 'Expected';
	}
	switch foo.getResult() {
		case Ok(_): throw 'Failed';
		case Error(e): assert(e.message == 'Expected');
	}
}

private function testMaybe() {
	var greeting:Maybe<String> = Some('hello');
	assert(greeting.map(greeting -> '$greeting world').or('none') == 'hello world');

	var noGreeting:Maybe<String> = None;
	assert(noGreeting.map(greeting -> '$greeting world').or('none') == 'none');
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
		values.extract([foo, bar]);
		assert(called == 2);
		assert(foo == 'foo');
		assert(bar == 'bar');
	});

	Future.parallel(new Future(activate -> activate('foo')), new Future(activate -> activate('bar'))).handle(values -> {
		values.extract([foo, bar]);
		assert(foo == 'foo');
		assert(bar == 'bar');
	});

	var future = new Future(activate -> activate('string'));
	var link = future.handle(value -> null);
	assert(link is CancellableLink);
}

private function testTask() {
	var foo:Task<String> = 'foo';
	foo.next(foo -> foo + 'bar').handle(result -> {
		result.extract(Ok(value));
		assert(value == 'foobar');
	});

	var foo:Task<String> = 'foo';
	foo.next(foo -> new Error(InternalError, 'expected')).recover(e -> {
		assert(e.message == 'expected');
		Task.resolve('foo');
	}).handle(result -> {
		result.extract(Ok(value));
		assert(value == 'foo');
	});

	var customError:Task<String, String> = Task.reject('reject');
	customError.next(foo -> 'foo').handle(result -> {
		result.extract(Error(str));
		assert(str == 'reject');
	});

	var convertsResult:Task<String> = Ok('foo');
	convertsResult.next(value -> Ok(value + 'bar')).handle(result -> {
		result.extract(Ok(value));
		assert(value == 'foobar');
	});

	var castsReturnObjectsIntoOk:Task<{foo:String}> = {foo: 'foo'};
	castsReturnObjectsIntoOk.next(obj -> {bar: 'bar', foo: obj.foo}).handle(obj -> {
		obj.extract(Ok({foo: foo, bar: bar}));
		assert(foo == 'foo');
		assert(bar == 'bar');
	});
}

private function testNothing() {
	var foo:Nothing = 'foo';
	assert(foo == Nothing);
}

private function testExtractSugar() {
	var foo:{a:String, b:Int} = {a: 'a', b: 1};
	foo.extract({a: a, b: b});
	assert(a == 'a');
	assert(b == 1);

	var foo:Maybe<String> = Some('foo');
	foo.extract(Some(actual));
	assert(actual == 'foo');

	var foo:Maybe<String> = None;
	foo.extract(Some(actual = 'foo'));
	assert(actual == 'foo');

	var foo:Maybe<String> = Some('foo');
	foo.ifExtract(Some(value), assert(value == 'foo'));

	var foo:Maybe<String> = None;
	foo.ifExtract(Some(value), {
		assert(value == 'foo');
	}, {
		assert(foo == None);
	});

	// Make sure nothing leaks into the parent scope:
	var foo:Maybe<String> = Some('foo');
	var value:String = 'bar';
	foo.ifExtract(Some(value), assert(value == 'foo'));
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

private function testNullSugar() {
	var foo:Null<String> = 'foo';
	foo.toMaybe().extract(Some(value));
	assert(value == 'foo');
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

private function testStream() {
	var stream = Stream.value('hello').append(Stream.value('world'));

	stream.collect().handle(result -> switch result {
		case Ok(values):
			var message = values.join(' ');
			trace(message);
			assert(message == 'hello world');
		default: throw 'Unexpected conclusion';
	});

	stream.map(value -> value.toUpperCase())
		.append(Stream.value('and stuff'))
		.reduce('', (accumulator, item) -> [accumulator, item].filter(t -> t.length > 0).join(' '))
		.handle(result -> switch result {
			case Ok(value):
				assert(value.print() == 'HELLO WORLD and stuff');
			default: throw 'Unexpected conclusion';
		});

	var buf = new StringBuf();
	stream.each(item -> buf.add(item)).handle(result -> switch result {
		case Depleted:
			assert(buf.toString().print() == 'helloworld');
		default: throw 'Unexpected conclusion';
	});
}
