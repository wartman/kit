package kit.spec;

import haxe.PosInfos;

final class Should<T> {
	static var currentSpec:Maybe<Spec> = None;

	public static function bind(spec:Spec) {
		switch currentSpec {
			case Some(_):
				// @todo: We can provide better info here
				throw 'Attempted to bind Assert while it was already bound';
			case None:
				currentSpec = Some(spec);
		}
	}

	public static function clear() {
		currentSpec = None;
	}

	public static function should<T>(subject:T) {
		return switch currentSpec {
			case Some(spec): new Should(subject, spec);
			default: throw 'Cannot use Assert outside of a spec';
		}
	}

	final subject:T;
	final spec:Spec;

	public function new(subject, spec) {
		this.subject = subject;
		this.spec = spec;
	}

	public function be(expected:T, ?pos:PosInfos) {
		if (subject != expected) {
			spec.addAssertion(Fail('Expected ${format(expected)} but was ${format(subject)}', pos));
		} else {
			spec.addAssertion(Pass);
		}
	}

	public function notBe(expected:T, ?pos:PosInfos) {
		if (subject == expected) {
			spec.addAssertion(Fail('Expected ${format(expected)} to not equal ${format(subject)}', pos));
		} else {
			spec.addAssertion(Pass);
		}
	}
}

private function format<T>(value:T) {
	return '`${Std.string(value)}`';
}
