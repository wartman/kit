package kit.macro2.step;

import kit.macro2.BuildHook;
import haxe.macro.Expr;

using Kit;
using kit.macro2.Tools;

class AutoInitializedFieldBuildStep implements BuildStep {
	public final priority:BuildPriority = BuildEarly;

	final options:{
		public final meta:String;
		public final ?hook:BuildHookName;
	};

	public function new(options) {
		this.options = options;
	}

	public function apply(build:Build) {
		build.fields
			.filterByMeta(':${options.meta}')
			.forEach(field -> parseField(build, field));
	}

	function parseField(build:Build, field:Field) {
		switch field.kind {
			case FVar(t, e):
				var name = field.name;
				build
					.hook(options.hook ?? Init)
					.addProp({
						name: name,
						type: t,
						doc: field.doc,
						optional: e != null
					})
					.addExpr(if (e == null) {
						macro this.$name = props.$name;
					} else {
						macro if (props.$name != null) this.$name = props.$name;
					});
			default:
				field.pos.error('Invalid field for :${options.meta}');
		}
	}
}
