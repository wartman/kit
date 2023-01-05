package kit.http;

import haxe.Exception;
import kit.ds.Result;

using Lambda;

class Headers {
	public static function parse(value:String):Result<Headers> {
		return Failure(new Exception('Not implemented yet'));
	}

	final fields:Array<HeaderField>;

	public function new(fields) {
		this.fields = fields;
	}

	public function get(name:HeaderName):Array<HeaderField> {
		return [for (field in fields) if (field.name == name) field];
	}

	public function has(name:HeaderName) {
		return fields.exists(field -> field.name == name);
	}

	public function with(header:HeaderField) {
		return new Headers(fields.concat([header]));
	}

	public function without(name:HeaderName) {
		return new Headers(fields.filter(field -> field.name != name));
	}

	public function clone() {
		return new Headers(fields.copy());
	}

	public function iterator() {
		return fields.iterator();
	}

	public function toString() {
		// todo
	}
}
