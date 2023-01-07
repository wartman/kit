package kit.test;

import haxe.PosInfos;

final class Should<T> {
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

	function format(value:T) {
		return '`${Std.string(value)}`';
	}
}
