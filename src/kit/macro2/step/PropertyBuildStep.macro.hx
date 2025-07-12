package kit.macro2.step;

using Kit;
using kit.macro2.Tools;

class PropertyBuildStep implements BuildStep {
	public final priority:BuildPriority = BuildEarly;

	public function new() {}

	public function apply(build:Build) {
		build.fields
			.filterByMeta(':prop')
			.forEach(field -> parseField(build, field));
	}

	function parseField(build:Build, field:FieldBuilder) {
		switch field.kind {
			case FVar(t, e):
				if (e != null) {
					e.pos.error('Expressions are not allowed in :prop fields');
				}

				var name = field.name;
				var getterName = 'get_$name';
				var setterName = 'set_$name';
				var meta = field.meta.get(':prop').unwrap();

				switch meta?.params {
					case [macro get = $expr]:
						field.kind = FProp('get', 'never', t);
						build.add(macro class {
							function $getterName():$t return $expr;
						});
					case [macro set = $expr]:
						field.kind = FProp('never', 'set', t);
						build.add(macro class {
							function $setterName(value : $t):$t return $expr;
						});
					case [macro get = $getter, macro set = $setter] | [macro set = $setter, macro get = $getter]:
						field.kind = FProp('get', 'set', t);
						build.add(macro class {
							function $getterName():$t return $getter;

							function $setterName(value : $t):$t return $setter;
						});
					case []:
						field.pos.error('Expected a getter and/or setter');
					default:
						field.pos.error('Invalid arguments for :prop');
				}
			default:
				field.pos.error('Invalid field for :prop');
		}
	}
}
