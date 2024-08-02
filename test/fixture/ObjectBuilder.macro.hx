package fixture;

import kit.macro.*;
import kit.macro.step.*;

function build() {
	return ClassBuilder.fromContext().use(new ObjectBuilder()).export();
}

class ObjectBuilder implements BuildBundle {
	public function new() {}

	public function steps():Array<BuildStep> return [
		new AutoInitializedFieldBuildStep({
			meta: 'auto',
			hook: Init
		}),
		new ConstructorBuildStep({
			hook: Init
		}),
		new PropertyBuildStep(),
		new JsonSerializerBuildStep()
	];
}
