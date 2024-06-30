package spec;

import haxe.Timer;

class FutureSuite extends Suite {
	function execute() {
		describe('kit.Future', () -> {
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
						values.extract(try [foo, bar]);
						called.should().be(2);
						foo.should().be('foo');
						bar.should().be('bar');
						Maybe.None;
					});
				});
				it('can process them in parallel', (spec:Spec) -> {
					spec.expect(2);

					return Future.parallel(new Future(activate -> activate('foo')), new Future(activate -> activate('bar'))).map(values -> {
						values.extract(try [foo, bar]);
						foo.should().be('foo');
						bar.should().be('bar');
						Maybe.None;
					});
				});
			});

			describe('If `handle` is never called', () -> {
				it('should not be activated', (spec:Spec) -> {
					spec.expect(0);

					var future = new Future(activate -> activate('foo'));
					future.map(foo -> foo.should().be('foo')); // should not be called

					return new Future<Result<Any, Any>>(activate -> {
						Timer.delay(() -> activate(Ok(Nothing)), 10);
					});
				});
			});

			describe('If `handle` is called', () -> {
				it('should return a cancellable link', () -> {
					var future = new Future(activate -> activate('string'));
					var link = future.handle(value -> Maybe.None);
					(link is CancellableLink).should().be(true);
				});
				it('should not call the callback if the cancellable is canceled', (spec:Spec) -> {
					spec.expect(0);
					// spec.wait(20);
					return new Future(outerActivate -> {
						var future = new Future<String>(activate -> {
							Timer.delay(() -> {
								activate('foo');
								outerActivate(Maybe.None);
							}, 20);
						});
						var link = future.handle(value -> value.should().be('foo'));
						link.cancel();
					});
				});
			});
		});
	}
}
