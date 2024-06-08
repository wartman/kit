package kit.http;

import haxe.Exception;

enum abstract Method(String) to String {
	static public function parse(s:String):Result<Method, Error> {
		return switch s.toUpperCase() {
			case 'GET': Ok(Get);
			case 'HEAD': Ok(Head);
			case 'OPTIONS': Ok(Options);
			case 'POST': Ok(Post);
			case 'PUT': Ok(Put);
			case 'PATCH': Ok(Patch);
			case 'DELETE': Ok(Delete);
			case other: return Error(new Error(InternalError, 'Invalid result: $other'));
		}
	}

	final Get = 'GET';
	final Head = 'HEAD';
	final Options = 'OPTIONS';
	final Post = 'POST';
	final Put = 'PUT';
	final Patch = 'PATCH';
	final Delete = 'DELETE';
}
