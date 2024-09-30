package kit;

import kit.Cancellable;
import haxe.Timer;

using kit.Testing;
using kit.Sugar;

class FutureSuite extends Suite {
	@:test(expects = 1, timeout = 100)
	function futuresWillActivate() {
		var future = new Future(activate -> activate('pass'));
		return future.map(value -> {
			value.equals('pass');
			value;
		});
	}

	@:test(expects = 1, timeout = 100)
	function futuresCanMapValues() {
		var foo = new Future(activate -> activate('foo'));
		return foo.map(foo -> foo + 'bar').map(bar -> bar + 'bin').map(value -> {
			value.equals('foobarbin');
			value;
		});
	}

	@:test(expects = 5, timeout = 100)
	function futuresCanRunInSequence() {
		var called = 0;
		return Future.sequence(new Future(activate -> {
			called.equals(0);
			called++;
			activate('foo');
		}), new Future(activate -> {
			called.equals(1);
			called++;
			activate('bar');
		})).map(values -> {
			values.extract(try [foo, bar]);
			called.equals(2);
			foo.equals('foo');
			bar.equals('bar');
			values;
		});
	}

	@:test(expects = 3, timeout = 100)
	function futuresCanRunInParallel() {
		return Future.parallel(
			new Future(activate -> activate('foo')),
			new Future(activate -> activate('bar'))
		).map(values -> {
			values.length.equals(2);
			values.extract(try [foo, bar]);
			foo.equals('foo');
			bar.equals('bar');
			values;
		});
	}

	@:test(expects = 1)
	function ifNoFuturesAreProvidedParallelWillStillActivate() {
		return Future.parallel().map(values -> {
			values.length.equals(0);
			values;
		});
	}

	@:test(expects = 1)
	function ifNoFuturesAreProvidedSequenceWillStillActivate() {
		return Future.sequence().map(values -> {
			values.length.equals(0);
			values;
		});
	}

	@:test(description = 'will not run if handle is never called', expects = 0, timeout = 100)
	function futuresAreLazy() {
		var future = new Future(activate -> activate('foo'));
		future.map(foo -> foo.equals('foo')); // should not be called
		return new Future(activate -> {
			Timer.delay(() -> activate('foo'), 10);
		});
	}

	@:test(description = 'returns a Cancellable type', expects = 1)
	function futuresAreCancellable() {
		var future = new Future(activate -> activate('string'));
		var link = future.handle(value -> value);
		(link is CancellableLink).equals(true);
	}

	@:test(description = 'will not run the handler if canceled', expects = 0, timeout = 200)
	function cancelActuallyWorks() {
		return new Future(outerActivate -> {
			var future = new Future<String>(activate -> {
				Timer.delay(() -> {
					activate('foo');
					outerActivate('foo');
				}, 20);
			});
			var link = future.handle(value -> Assert.fail('Should not run'));
			link.cancel();
		});
	}
}
