package kit.test;

final class Outcome {
	public final suites:Array<SuiteOutcome>;

	public function new(suites) {
		this.suites = suites;
	}
}

final class SuiteOutcome {
	public final description:String;
	public final tests:Array<TestOutcome>;

	public function new(description, tests) {
		this.description = description;
		this.tests = tests;
	}

	public function status():SuiteOutcomeStatus {
		return {
			total: tests.length,
			passed: tests.filter(s -> s.status().failed == 0).length,
			failed: tests.filter(s -> s.status().failed > 0).length,
		}
	}
}

typedef SuiteOutcomeStatus = {passed:Int, failed:Int, total:Int};

final class TestOutcome {
	public final description:String;
	public final assertions:Array<Assertion>;

	public function new(description, assertions) {
		this.description = description;
		this.assertions = assertions;
	}

	public function status():SpecOutcomeStatus {
		return {
			passed: assertions.filter(a -> a.equals(Pass)).length,
			failed: assertions.filter(a -> !a.equals(Pass)).length
		}
	};
}

typedef SpecOutcomeStatus = {passed:Int, failed:Int};
