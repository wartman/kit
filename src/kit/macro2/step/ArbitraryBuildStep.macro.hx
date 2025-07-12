package kit.macro2.step;

class ArbitraryBuildStep implements BuildStep {
	public final priority:BuildPriority;

	final applicator:(build:Build) -> Void;

	public function new(priority, applicator) {
		this.priority = priority;
		this.applicator = applicator;
	}

	public function apply(build:Build) {
		applicator(build);
	}
}
