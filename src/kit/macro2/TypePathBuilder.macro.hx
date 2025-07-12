package kit.macro2;

import haxe.macro.Context;
import haxe.macro.Expr;

@:forward
abstract TypePathBuilder(TypePath) to TypePath {
	@:from public static inline function of(path) {
		return new TypePathBuilder(path);
	}

	public inline function new(path) {
		this = path;
	}

	public function exists() {
		try {
			return Context.getType(toString()) != null;
		} catch (e:String) {
			return false;
		}
	}

	@:to public function toArray():Array<String> {
		return this.pack.concat([this.name, this.sub]).filter(s -> s != null);
	}

	@:to public function toString():String {
		return toArray().join('.');
	}
}
