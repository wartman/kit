package kit.http;

import haxe.Json;
import haxe.io.Bytes;

// @todo: Make this into a stream?
abstract Body(Bytes) from Bytes {
	@:from public inline static function ofString(str:String):Body {
		return Bytes.ofString(str);
	}

	@:from public inline static function ofJson<T:{}>(data:T):Body {
		return Bytes.ofString(Json.stringify(data));
	}

	public inline function new(bytes) {
		this = bytes;
	}

	@:to public inline function toBytes():Bytes {
		return this;
	}
}
