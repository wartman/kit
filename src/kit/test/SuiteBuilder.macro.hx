package kit.test;

import haxe.macro.Expr;
import kit.macro.*;

using haxe.macro.Tools;
using kit.macro.Tools;

final TestRunnerHook = 'kit.test:test-runner';

function build() {
	return ClassBuilder.fromContext().use(new SuiteBuilder()).export();
}

class SuiteBuilder implements BuildBundle implements BuildStep {
	public final priority:Priority = Late;

	public function new() {}

	public function steps():Array<BuildStep> return [
		new TestFieldBuildStep(),
		new BeforeFieldBuildStep(),
		new AfterFieldBuildStep(),
		this
	];

	public function apply(builder:ClassBuilder) {
		var tests = builder.hook(TestRunnerHook).getExprs();
		var description = builder.getType().toString();

		switch builder.getClass().meta.extract(':description') {
			case []:
			case [meta]:
				switch meta.params {
					case [desc]:
						description = description + ': ' + desc.extractString();
					default:
						meta.pos.error('Expected one param');
				}
			case tooMany:
				tooMany[tooMany.length - 1].pos.error('Only one :description param is allowed');
		}

		builder.add(macro class {
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
	public final priority:Priority = Normal;

	public function new() {}

	public function apply(builder:ClassBuilder) {
		for (field in builder.findFieldsByMeta(':test')) {
			parseField(builder, field);
		}
	}

	function parseField(builder:ClassBuilder, field:Field) {
		var meta = field.getMetadata(':test');

		if (meta == null) {
			field.pos.error('No :test metadata found');
		}

		switch field.kind {
			case FFun(f):
				var name = field.name;
				var options = meta.extractOptions(['description', 'expects']);
				var description = options.get('description')?.extractString() ?? toSentence(name);
				var expects = options.get('expects') ?? macro null;

				builder.hook(TestRunnerHook).addExpr(macro new kit.test.Test(
					this.events,
					$v{description},
					this.$name,
					$expects
				));
			default:
				field.pos.error(':test fields must be methods');
		}
	}
}

// @todo
class BeforeFieldBuildStep implements BuildStep {
	public final priority:Priority = Normal;

	public function new() {}

	public function apply(builder:ClassBuilder) {}
}

// @todo
class AfterFieldBuildStep implements BuildStep {
	public final priority:Priority = Normal;

	public function new() {}

	public function apply(builder:ClassBuilder) {}
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
