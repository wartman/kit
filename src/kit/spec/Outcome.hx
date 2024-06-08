package kit.spec;

final class Outcome {
	public final suites:Array<SuiteOutcome>;

	public function new(suites) {
		this.suites = suites;
	}
}

final class SuiteOutcome {
	public final description:String;
	public final specs:Array<SpecOutcome>;
	public final children:Array<SuiteOutcome>;

	public function new(description, specs, ?children) {
		this.description = description;
		this.specs = specs;
		this.children = children == null ? [] : children;
	}

	public function status():SuiteOutcomeStatus {
		return {
			total: specs.length,
			passed: specs.filter(s -> s.status().failed == 0).length,
			failed: specs.filter(s -> s.status().failed > 0).length,
		}
	}
}

typedef SuiteOutcomeStatus = {passed:Int, failed:Int, total:Int};

final class SpecOutcome {
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
