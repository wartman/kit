package kit;

using kit.Testing;
using kit.Sugar;

enum abstract Errors(String) {
	final NotFoo = 'Expected Foo';
	final NotBar = 'Expected Bar';
}

enum OtherErrors {
	NotFound;
	TooLong(length:Int);
}

typedef ErrorList = Or<Errors, OtherErrors>;
typedef StringOrInt = Or<String, Int>;

class OrSuite extends Suite {
	@:test
	function worksWithPrimitiveTypes() {
		var data:Or<String, Int> = 'foo';
		data.unwrap().extract(try OrString(value));
		value.equals('foo');

		data = 1;
		data.unwrap().extract(try OrInt(value));
		value.equals(1);
	}

	@:test(expects = 2)
	function hasMethodsForQuicklyExtractingTypes() {
		var data:Or<String, Int> = 1;
		data.toInt().unwrap()?.equals(1);
		data.tryInt().equals(1);
	}

	@:test(expects = 1)
	function createsAnAbstractThatCanMergeTypes() {
		var err:ErrorList = Errors.NotFoo;
		err.toErrors().inspect(err -> err.equals(NotFoo));
	}

	@:test(description = 'creates the same type regardless of the order of type params -- for example, Or<String, Int> is the same as Or<Int, String>.',
		expects = 1)
	function wontCreateTooMayTypes() {
		var a:Or<String, Int> = 'Foo';
		var b:Or<Int, String> = 'Foo';
		a.tryString().equals(b.tryString());
	}

	@:test(expects = 1)
	function worksWithTasks() {
		function failToGetInt():Task<String, Int> {
			return Task.reject(1);
		}

		// It would be great for this to happen automatically,
		// but I don't think Haxe's type system can handle that.
		//
		// Still useful?
		function test():Task<String, StringOrInt> {
			return failToGetInt().mapError(StringOrInt.fromInt);
		}

		return test().inspectError(error -> switch error.unwrap() {
			case OrInt(1): Assert.pass();
			default:
		}).recover(_ -> Future.immediate('Ok'));
	}
}
