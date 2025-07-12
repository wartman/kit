package fixture;

import kit.macro2.*;
import kit.macro2.step.*;

function build() {
	return BuildFactory
		.fromBundle(new ObjectBuilder())
		.buildFromContext();
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
