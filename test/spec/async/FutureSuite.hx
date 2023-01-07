package spec.async;

import haxe.Timer;

class FutureSuite extends Suite {
	function execute() {
		describe('Given a value', () -> {
			it('will be handled immediately', () -> {
				var future = new Future(activate -> activate('pass'));
				return future.map(value -> {
					value.should().be('pass');
					value;
				});
			});
			it('can be mapped to other values', () -> {
				var foo = new Future(activate -> activate('foo'));
				return foo.map(foo -> foo + 'bar').map(bar -> bar + 'bin').map(value -> {
					value.should().be('foobarbin');
					value;
				});
			});
		});

		describe('Given multiple Futures', () -> {
			it('can process them in sequence', (spec:Spec) -> {
				spec.expect(5);

				var called = 0;
				Future.sequence(new Future(activate -> {
					called.should().be(0);
					called++;
					activate('foo');
				}), new Future(activate -> {
					called.should().be(1);
					called++;
					activate('bar');
				})).map(values -> {
					values.extract([var foo, var bar]);
					called.should().be(2);
					foo.should().be('foo');
					bar.should().be('bar');
					Empty;
				});
			});
			it('can process them in parallel', (spec:Spec) -> {
				spec.expect(2);

				return Future.parallel(new Future(activate -> activate('foo')), new Future(activate -> activate('bar'))).map(values -> {
					values.extract([var foo, var bar]);
					foo.should().be('foo');
					bar.should().be('bar');
					Empty;
				});
			});
		});

		describe('If `handle` is never called', () -> {
			it('should not be activated', (spec:Spec) -> {
				spec.expect(0);

				var future = new Future(activate -> activate('foo'));
				future.map(foo -> foo.should().be('foo')); // should not be called

				return new Future<Result<Empty>>(activate -> {
					Timer.delay(() -> activate(Success(Empty)), 10);
				});
			});
		});
	}
}
