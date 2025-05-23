package kit;

import haxe.Exception;

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

@:forward
@:forward.new
abstract Error(ErrorObject) from ErrorObject to Exception {
	public static function maybeError(e:Exception):Maybe<Error> {
		return isError(e) ? Some((cast e : ErrorObject)) : None;
	}

	@:noUsing
	public inline static function isError(other:Exception) {
		return other is ErrorObject;
	}

	@:noUsing
	@:from public static function ofException(e:Exception):Error {
		if (isError(e)) return (cast e : ErrorObject);
		return new Error(InternalError, e.message);
	}

	public var code(get, never):ErrorCode;

	function get_code():ErrorCode {
		return @:privateAccess this.errorCode;
	}
}

private class ErrorObject extends Exception {
	final errorCode:ErrorCode;

	public function new(errorCode, message) {
		super(message);
		this.errorCode = errorCode;
	}
}
