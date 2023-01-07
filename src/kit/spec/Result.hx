package kit.spec;

final class Result {
	public final suites:Array<SuiteResult>;

	public function new(suites) {
		this.suites = suites;
	}
}

final class SuiteResult {
	public final description:String;
	public final specs:Array<SpecResult>;
	public final children:Array<SuiteResult>;

	public function new(description, specs, ?children) {
		this.description = description;
		this.specs = specs;
		this.children = children == null ? [] : children;
	}

	public function status():SuiteResultStatus {
		return {
			total: specs.length,
			passed: specs.filter(s -> s.status().failed == 0).length,
			failed: specs.filter(s -> s.status().failed > 0).length,
		}
	}
}

typedef SuiteResultStatus = {passed:Int, failed:Int, total:Int};

final class SpecResult {
	public final description:String;
	public final assertions:Array<Assertion>;

	public function new(description, assertions) {
		this.description = description;
		this.assertions = assertions;
	}

	public function status():SpecResultStatus {
		return {
			passed: assertions.filter(a -> a.equals(Pass)).length,
			failed: assertions.filter(a -> !a.equals(Pass)).length
		}
	};
}

typedef SpecResultStatus = {passed:Int, failed:Int};
