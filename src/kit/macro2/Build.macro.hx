package kit.macro2;

import haxe.macro.Expr;

using Kit;
using Lambda;

class Build {
	public final type:TypeBuilder;
	public final fields:FieldCollection;

	final steps:Array<BuildStep>;
	final hooks:Array<BuildHook> = [];

	public function new(type, steps, fields) {
		this.type = type;
		this.steps = steps;
		this.fields = fields;
	}

	public function hook(name):BuildHook {
		return hooks.find(hook -> hook.name == name) ?? {
			var hook = new BuildHook(name);
			hooks.push(hook);
			hook;
		};
	}

	public function add(t:TypeDefinition) {
		fields.add(t);
		return this;
	}

	public function export() {
		inline function applySteps(priority:BuildPriority) {
			steps.filter(b -> b.priority == priority).forEach(builder -> builder.apply(this));
		}

		applySteps(BuildEarly);
		applySteps(BuildNormal);
		applySteps(BuildLate);

		return fields.export();
	}
}
