package fixture;

import kit.macro.*;
import kit.macro.step.*;

function build() {
	return ClassBuilder.fromContext()
		.step(new AutoInitializedFieldBuildStep({
			meta: 'auto',
			hook: Init
		}))
		.step(new ConstructorBuildStep({
			hook: Init
		}))
		.step(new PropertyBuildStep())
		.step(new JsonSerializerBuildStep())
		.export();
}
