package unit.async;

import haxe.Timer;
import kit.async.Future;

using Medic;
using kit.core.Sugar;

class TestFuture implements TestCase {
	public function new() {}

	@:test('Simple future works')
	@:test.async
	function testFuture(done) {
		var future = new Future(activate -> activate('pass'));
		future.handle(value -> {
			value.equals('pass');
			done();
		});
	}

	@:test('Futures can be run in sequence')
	@:test.async
	function testSequence(done) {
		var called = 0;
		Future.sequence(new Future(activate -> {
			called.equals(0);
			called++;
			activate('foo');
		}), new Future(activate -> {
			called.equals(1);
			called++;
			activate('bar');
		})).handle(values -> {
			values.extract([var foo, var bar]);
			called.equals(2);
			foo.equals('foo');
			bar.equals('bar');
			done();
		});
	}

	@:test('Futures can be run in parallel')
	@:test.async
	function testParallel(done) {
		// @todo: We can test this with timers or something?
		Future.parallel(new Future(activate -> activate('foo')), new Future(activate -> activate('bar'))).handle(values -> {
			values.extract([var foo, var bar]);
			foo.equals('foo');
			bar.equals('bar');
			done();
		});
	}

	@:test('Futures can be mapped')
	@:test.async
	function testMapping(done) {
		var foo = new Future(activate -> activate('foo'));
		foo.map(foo -> foo + 'bar').map(bar -> bar + 'bin').handle(value -> {
			value.equals('foobarbin');
			done();
		});
	}

	@:test('Futures can be flatMapped')
	@:test.async
	function testFlatMapping(done) {
		var foo = new Future(activate -> activate('foo'));
		foo.flatMap(foo -> new Future(activate -> activate(foo + 'bar'))).flatMap(bar -> new Future(activate -> activate(bar + 'bin'))).handle(value -> {
			value.equals('foobarbin');
			done();
		});
	}

	@:test('Futures are lazy and will not be invoked until handle is called')
	@:test.async
	function testLaziness(done) {
		new Future(activate -> {
			Assert.fail('Activation function was called.');
			activate('foo');
		});
		Timer.delay(() -> {
			Assert.pass();
			done();
		}, 10);
	}
}
