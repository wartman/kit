package kit.macro2;

import haxe.macro.Expr;

using Lambda;

@:forward
abstract FieldBuilder(Field) from Field {
	public var meta(get, never):MetadataCollection;

	function get_meta() {
		return new MetadataCollection(this.meta);
	}

	@:to public function unwrap():Field {
		return this;
	}

	public function applyParameters(params:Array<TypeParamDecl>) {
		switch this.kind {
			case FFun(f):
				f.params = params;
			default:
				// todo
		}
		return abstract;
	}
}
