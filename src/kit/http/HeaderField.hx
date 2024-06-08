package kit.http;

@:forward
abstract HeaderField(HeaderFieldObject) from HeaderFieldObject {
	public inline function new(name, value:Any) {
		this = {name: name, value: Std.string(value)};
	}
}

typedef HeaderFieldObject = {
	public final name:HeaderName;
	public final value:String;
}
