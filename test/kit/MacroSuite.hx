package kit;

import fixture.Name;

using kit.Testing;

@:description('test the macro library using a simple class that represents a name.')
class MacroSuite extends Suite {
	@:test(description = '@:auto add props to the constructor', expects = 2)
	function automaticConstructorArgs() {
		var name = new Name({first: 'Guy', last: 'Manly'});
		name.first.equals('Guy');
		name.last.equals('Manly');
	}

	@:test(description = '@:prop converts a field into a property', expects = 1)
	function fieldIntoProperty() {
		var name = new Name({first: 'Guy', last: 'Manly'});
		name.full.equals('Guy Manly');
	}
}
