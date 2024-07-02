package kit.macro.step;

class ArbitraryBuildStep implements BuildStep {
	public final priority:Priority;

	final applicator:(builder:ClassBuilder) -> Void;

	public function new(priority, applicator) {
		this.priority = priority;
		this.applicator = applicator;
	}

	public function apply(builder:ClassBuilder) {
		applicator(builder);
	}
}
