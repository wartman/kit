package kit.test;

import haxe.Timer;
import haxe.PosInfos;
import kit.test.Outcome;

class Test {
	final events:Events;
	final description:String;
	final assertions:Array<Assertion> = [];
	final body:TestBody;
	final timeout:Maybe<Int>;
	final expects:Maybe<Int>;

	public function new(events, description, body, ?expects, ?timeout) {
		this.events = events;
		this.description = description;
		this.body = body;
		this.expects = expects == null ? None : Some(expects);
		this.timeout = timeout == null ? None : Some(timeout);
	}

	public function addAssertion(assertion:Assertion) {
		assertions.push(assertion);
		events.onAssertion.dispatch(assertion);
	}

	public function run(?pos:PosInfos):Task<TestOutcome> {
		if (body == null) {
			addAssertion(Warn('Incomplete spec'));
			var outcome = new TestOutcome(description, assertions);
			return Task.ok(outcome);
		}

		return new Task(activate -> {
			Assert.bind(this);
			var handled = false;
			var link = body.invoke().handle(res -> {
				handled = true;
				switch res {
					case Ok(_):
						Assert.clear();

						switch expects {
							case None:
								if (assertions.length == 0) addAssertion(Warn('No assertions'));
							case Some(0) if (assertions.length != 0):
								addAssertion(Fail('Expected no assertions but asserted ${assertions.length}', pos));
							case Some(count) if (count != assertions.length):
								addAssertion(Fail('Expected ${count} but asserted ${assertions.length}', pos));
							case Some(_):
						}

						var outcome = new TestOutcome(description, assertions);

						events.onTestComplete.dispatch(outcome);

						activate(Ok(outcome));
					case Error(error):
						Assert.clear();
						addAssertion(Fail(error.message));
						var outcome = new TestOutcome(description, assertions);
						activate(Ok(outcome));
				}
			});

			Timer.delay(() -> {
				if (!handled) {
					link.cancel();
					handled = true;
					Assert.clear();
					addAssertion(Fail('Test timed out after ${timeout.or(1000)}ms'));

					var outcome = new TestOutcome(description, assertions);

					events.onTestComplete.dispatch(outcome);

					activate(Ok(outcome));
				}
			}, timeout.or(1000));
		});
	}
}

abstract TestBody(SpecBodyType) {
	@:from public inline static function ofSync(cb:() -> Void):TestBody {
		return new TestBody(Sync(cb));
	}

	@:from public inline static function ofTask<T>(cb:() -> Task<T>):TestBody {
		return new TestBody(Async(cb));
	}

	@:from public inline static function ofFuture<T>(cb:() -> Future<T>):TestBody {
		return new TestBody(Async(() -> (cb() : Task<Any>)));
	}

	public inline function new(body) {
		this = body;
	}

	public function invoke():Task<Nothing> {
		return switch this {
			case Sync(cb):
				cb();
				Task.nothing();
			case Async(cb):
				cb();
		}
	}
}

enum SpecBodyType {
	Sync(cb:() -> Void);
	Async(cb:() -> Task<Any>);
}
