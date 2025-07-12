package kit.macro2;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import kit.macro2.step.*;

abstract BuildFactory(Array<BuildStep>) {
	public inline static function fromSteps(steps) {
		return new BuildFactory(steps);
	}

	public inline static function fromBundle(bundle) {
		return new BuildFactory().withBundle(bundle);
	}

	public function new(?steps:Array<BuildStep>) {
		this = steps ?? [];
	}

	public function withBundle(bundle:BuildBundle) {
		for (step in bundle.steps()) withStep(step);
		return abstract;
	}

	public function withStep(step:BuildStep) {
		this.push(step);
		return abstract;
	}

	public inline function pipe(applicator, ?priority:BuildPriority) {
		return withStep(new ArbitraryBuildStep(priority ?? BuildNormal, applicator));
	}

	public function build(type:Type, fields:Array<Field>) {
		var build = new Build(type, this, new FieldCollection(fields));
		return build.export();
	}

	public function buildFromContext() {
		return build(Context.getLocalType(), Context.getBuildFields());
	}
}
