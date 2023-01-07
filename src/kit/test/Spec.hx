package kit.test;

import haxe.PosInfos;
import kit.async.Future;
import kit.async.Task;
import kit.ds.Empty;
import kit.test.Result;

@:allow(kit.test)
final class Spec {
	final description:String;
	final body:Null<SpecBody>;
	final assertions:Array<Assertion> = [];
	final events:Events;
	var expectsAssertions:Null<Int> = null;

	public function new(events, description, body) {
		this.events = events;
		this.description = description;
		this.body = body;
	}

	public function expect(count:Int) {
		this.expectsAssertions = count;
	}

	public function addAssertion(assertion:Assertion) {
		assertions.push(assertion);
		events.onAssertion.dispatch(assertion);
	}

	public function should<T>(subject:T):Should<T> {
		return new Should(subject, this);
	}

	public function run(?pos:PosInfos):Task<SpecResult> {
		if (body == null) {
			addAssertion(Warn('Incomplete spec'));
			var result = new SpecResult(description, assertions);
			return Task.ofSync(result);
		}

		// @todo: Add timeout
		return new Future<kit.ds.Result<SpecResult>>(activate -> {
			Assert.bind(this);
			body.invoke(this).handle(res -> switch res {
				case Success(_):
					Assert.clear();

					switch expectsAssertions {
						case null:
							if (assertions.length == 0) addAssertion(Warn('No assertions'));
						case 0 if (assertions.length != 0):
							addAssertion(Fail('Expected no assertions but asserted ${assertions.length}', pos));
						case count if (count != assertions.length):
							addAssertion(Fail('Expected ${count} but asserted ${assertions.length}', pos));
					}

					var result = new SpecResult(description, assertions);

					events.onSpecComplete.dispatch(result);

					activate(Success(result));
				case Failure(exception):
					Assert.clear();
					addAssertion(Fail(exception.message));
					var result = new SpecResult(description, assertions);
					activate(Success(result));
			});
		});
	}
}

abstract SpecBody(SpecBodyType) {
	@:from public inline static function ofWrappedSync(cb:() -> Void):SpecBody {
		return ofSync(_ -> cb());
	}

	@:from public inline static function ofWrappedTask<T>(cb:() -> Task<T>):SpecBody {
		return ofTask(_ -> cb());
	}

	@:from public inline static function ofWrappedFuture<T>(cb:() -> Future<T>):SpecBody {
		return ofTask(_ -> cb());
	}

	@:from public inline static function ofSync(cb:(spec:Spec) -> Void):SpecBody {
		return new SpecBody(Sync(cb));
	}

	@:from public inline static function ofTask<T>(cb:(spec:Spec) -> Task<T>):SpecBody {
		return new SpecBody(Async(cb));
	}

	@:from public inline static function ofFuture<T>(cb:(spec:Spec) -> Future<T>):SpecBody {
		return new SpecBody(Async(spec -> (cb(spec) : Task<Any>)));
	}

	public inline function new(body) {
		this = body;
	}

	public inline function invoke(spec:Spec):Task<Any> {
		return switch this {
			case Sync(cb):
				cb(spec);
				Empty;
			case Async(cb):
				cb(spec);
		}
	}
}

enum SpecBodyType {
	Sync(cb:(spec:Spec) -> Void);
	Async(cb:(spec:Spec) -> Task<Any>);
}
