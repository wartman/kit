package kit.macro2;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;

@:forward
abstract TypeBuilder(Type) from Type {
	@:from public static function fromString(path:String) {
		return new TypeBuilder(Context.getType(path));
	}

	@:from public static function fromComplexType(ct:ComplexType) {
		return new TypeBuilder(ct.toType());
	}

	public function new(type) {
		this = type;
	}

	public function unify(other:TypeBuilder):Bool {
		return Context.unify(this, other.unwrap());
	}

	@:to public function toComplexType():ComplexType {
		return this.toComplexType();
	}

	// @todo: This is not correct and cannot deal with sub paths. Also only works
	// on Class builds.
	@:to public function toTypePath():TypePath {
		var cls = toClassType();
		return {
			pack: cls.pack,
			name: cls.name
		};
	}

	@:to public function toClassType():ClassType {
		return this.getClass();
	}

	@:to public function unwrap():Type {
		return this;
	}
}
