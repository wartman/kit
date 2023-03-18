package kit;

import haxe.Exception;
import haxe.PosInfos;

enum abstract ErrorCode(Int) from Int {
	final BadRequest = 400;
	final Unauthorized = 401;
	final Forbidden = 403;
	final NotFound = 404;
	final MethodNotAllowed = 405;
	final NotAcceptable = 406;
	final RequestTimeout = 408;
	final Conflict = 409;
	final Gone = 410;
	final UnsupportedMediaType = 415;
	final ExpectationFailed = 417;
	final InternalError = 500;
	final NotImplemented = 501;
	final ServiceUnavailable = 503;
	final InsufficientStorage = 507;
	final LoopDetected = 508;
}

typedef ErrorObject = {
	public final code:ErrorCode;
	public final message:String;
}

// @todo: Unsure about this one. Should it extend Exception?
// Is it even needed? We're just copying Tink here because I found
// Errors and their ErrorCodes to be useful, but maybe there's a
// better way.

@:forward(code, message)
abstract Error(ErrorObject) from ErrorObject {
	@:from public static function ofException(e:Exception) {
		return new Error(InternalError, e.toString());
	}

	public inline function new(code, message) {
		this = {code: code, message: message};
	}

	@:to public function toProduct<T>():Product<T> {
		return Error(this);
	}

	@:to public function toString():String {
		return '${this.code} ${this.message}';
	}

	public function asException(?pos:PosInfos) {
		return new Exception(toString(), pos);
	}

	public inline function throwError(?pos:PosInfos) {
		throw asException(pos);
	}
}
