package kit.test;

import haxe.macro.Expr;
import kit.macro2.*;

using Kit;
using haxe.macro.Tools;
using kit.macro2.Tools;

final TestRunnerHook = 'kit.test:test-runner';

function build() {
	return BuildFactory
		.fromBundle(new SuiteBuilder())
		.buildFromContext();
}

class SuiteBuilder implements BuildBundle implements BuildStep {
	public final priority:BuildPriority = BuildLate;

	public function new() {}

	public function steps():Array<BuildStep> return [
		new TestFieldBuildStep(),
		this
	];

	public function apply(build:Build) {
		var tests = build.hook(TestRunnerHook).getExprs();
		var description = build.type.toString();

		switch build.type.getClass().meta.extract(':description') {
			case []:
			case [meta]:
				switch meta.params {
					case [desc]:
						description = description + ': ' + desc.getValue();
					default:
						meta.pos.error('Expected one param');
				}
			case tooMany:
				tooMany[tooMany.length - 1].pos.error('Only one :description param is allowed');
		}

		build.add(macro class {
			function getDescription() {
				return $v{description};
			}

			function getTests():Array<kit.test.Test> {
				return [$a{tests}];
			}
		});
	}
}

class TestFieldBuildStep implements BuildStep {
	public final priority:BuildPriority = BuildNormal;

	public function new() {}

	public function apply(build:Build) {
		build.fields
			.filterByMeta(':test')
			.forEach(field -> {
				var options = field.meta
					.options(':test', ['description', 'expects', 'timeout'])
					.unwrap();

				if (options == null) {
					field.pos.error('No :test metadata found');
				}

				switch field.kind {
					case FFun(f):
						var name = field.name;
						var description = options.get('description')?.getValue() ?? toSentence(name);
						var expects = options.get('expects') ?? macro null;
						var timeout = options.get('timeout') ?? macro null;

						build.hook(TestRunnerHook).addExpr(macro new kit.test.Test(
							this.events,
							$v{description},
							this.$name,
							$expects,
							$timeout
						));
					default:
						field.pos.error(':test fields must be methods');
				}
			});
	}
}

function toSentence(name:String) {
	var chars = [];
	for (i in 0...name.length) {
		var char = name.charAt(i);
		if (char >= 'A' && char <= 'Z') {
			chars.push(' ');
			chars.push(char.toLowerCase());
		} else if (char == '_') {
			chars.push(' ');
		} else {
			chars.push(char);
		}
	}
	return chars.join('');
}
