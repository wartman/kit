package kit.macro2;

interface BuildStep {
	public final priority:BuildPriority;
	public function apply(build:Build):Void;
}
