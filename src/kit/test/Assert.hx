package kit.test;

import haxe.PosInfos;

@:allow(kit.test)
class Assert {
	static var currentTest:Maybe<Test> = None;

	@:noUsing
	static function bind(test:Test) {
		switch currentTest {
			case Some(_):
				// @todo: We can provide better info here
				throw 'Attempted to bind Assert while it was already bound';
			case None:
				currentTest = Some(test);
		}
	}

	static function clear() {
		currentTest = None;
	}

	static function current():Test {
		return currentTest.orThrow('No test currently bound');
	}

	public static function fail(message:String, ?pos:PosInfos) {
		current().addAssertion(Fail(message, pos));
	}

	public static function pass() {
		current().addAssertion(Pass);
	}

	public static function equals<T>(subject:T, expected:T, ?pos:PosInfos) {
		if (subject != expected) {
			current().addAssertion(Fail('Expected ${Std.string(expected)} but was ${Std.string(subject)}', pos));
		} else {
			current().addAssertion(Pass);
		}
	}

	public static function notEquals<T>(subject:T, expected:T, ?pos:PosInfos) {
		if (subject != expected) {
			current().addAssertion(Fail('Expected ${Std.string(expected)} to not equal ${Std.string(subject)}', pos));
		} else {
			current().addAssertion(Pass);
		}
	}
}
