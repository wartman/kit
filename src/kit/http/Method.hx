package kit.http;

import haxe.Exception;
import kit.ds.Result;

enum abstract Method(String) to String {
	static public function parse(s:String):Result<Method> {
		return switch s.toUpperCase() {
			case 'GET': Success(Get);
			case 'HEAD': Success(Head);
			case 'OPTIONS': Success(Options);
			case 'POST': Success(Post);
			case 'PUT': Success(Put);
			case 'PATCH': Success(Patch);
			case 'DELETE': Success(Delete);
			case other: return Failure(new Exception('Invalid result: $other'));
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
