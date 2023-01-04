package unit.async;

import kit.async.Future;
import kit.core.Lazy;

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
		Future.sequence(new Lazy(() -> {
			called.equals(0);
			called++;
			new Future(activate -> activate('foo'));
		}), new Lazy(() -> {
			called.equals(1);
			called++;
			new Future(activate -> activate('bar'));
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
}
