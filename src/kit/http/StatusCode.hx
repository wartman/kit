package kit.http;

import kit.Error;

enum abstract StatusCode(Int) from Int to Int {
	final Continue = 100;
	final SwitchingProtocols = 101;
	final Processing = 102;
	final OK = 200;
	final Created = 201;
	final Accepted = 202;
	final NonAuthoritativeInformation = 203;
	final NoContent = 204;
	final ResetContent = 205;
	final PartialContent = 206;
	final MultiStatus = 207;
	final AlreadyReported = 208;
	final IMUsed = 226;
	final MultipleChoices = 300;
	final MovedPermanently = 301;
	final Found = 302;
	final SeeOther = 303;
	final NotModified = 304;
	final UseProxy = 305;
	final SwitchProxy = 306;
	final TemporaryRedirect = 307;
	final PermanentRedirect = 308;
	final BadRequest = 400;
	final Unauthorized = 401;
	final PaymentRequired = 402;
	final Forbidden = 403;
	final NotFound = 404;
	final MethodNotAllowed = 405;
	final NotAcceptable = 406;
	final ProxyAuthenticationRequired = 407;
	final RequestTimeout = 408;
	final Conflict = 409;
	final Gone = 410;
	final LengthRequired = 411;
	final PreconditionFailed = 412;
	final PayloadTooLarge = 413;
	final URITooLong = 414;
	final UnsupportedMediaType = 415;
	final RangeNotSatisfiable = 416;
	final ExpectationFailed = 417;
	final ImATeapot = 418;
	final MisdirectedRequest = 421;
	final UnprocessableEntity = 422;
	final Locked = 423;
	final FailedDependency = 424;
	final UpgradeRequired = 426;
	final PreconditionRequired = 428;
	final TooManyRequests = 429;
	final RequestHeaderFieldsTooLarge = 431;
	final UnavailableForLegalReasons = 451;
	final InternalServerError = 500;
	final NotImplemented = 501;
	final BadGateway = 502;
	final ServiceUnavailable = 503;
	final GatewayTimeout = 504;
	final HTTPVersionNotSupported = 505;
	final VariantAlsoNegotiates = 506;
	final InsufficientStorage = 507;
	final LoopDetected = 508;
	final NotExtended = 510;
	final NetworkAuthenticationRequired = 511;

	@:from public static function fromErrorCode(code:ErrorCode):StatusCode {
		return switch code {
			case ErrorCode.BadRequest: BadRequest;
			case ErrorCode.Unauthorized: Unauthorized;
			case ErrorCode.Forbidden: Forbidden;
			case ErrorCode.NotFound: NotFound;
			case ErrorCode.MethodNotAllowed: MethodNotAllowed;
			case ErrorCode.NotAcceptable: NotAcceptable;
			case ErrorCode.RequestTimeout: RequestTimeout;
			case ErrorCode.Conflict: Conflict;
			case ErrorCode.Gone: Gone;
			case ErrorCode.UnsupportedMediaType: UnsupportedMediaType;
			case ErrorCode.ExpectationFailed: ExpectationFailed;
			case ErrorCode.InternalError: InternalServerError;
			case ErrorCode.NotImplemented: NotImplemented;
			case ErrorCode.ServiceUnavailable: ServiceUnavailable;
			case ErrorCode.InsufficientStorage: InsufficientStorage;
			case ErrorCode.LoopDetected: LoopDetected;
		}
	}

	@:to public function toErrorCode():ErrorCode {
		return switch this {
			case BadRequest: ErrorCode.BadRequest;
			case Unauthorized: ErrorCode.Unauthorized;
			case Forbidden: ErrorCode.Forbidden;
			case NotFound: ErrorCode.NotFound;
			case MethodNotAllowed: ErrorCode.MethodNotAllowed;
			case NotAcceptable: ErrorCode.NotAcceptable;
			case RequestTimeout: ErrorCode.RequestTimeout;
			case Conflict: ErrorCode.Conflict;
			case Gone: ErrorCode.Gone;
			case UnsupportedMediaType: ErrorCode.UnsupportedMediaType;
			case ExpectationFailed: ErrorCode.ExpectationFailed;
			case InternalServerError: ErrorCode.InternalError;
			case NotImplemented: ErrorCode.NotImplemented;
			case ServiceUnavailable: ErrorCode.ServiceUnavailable;
			case InsufficientStorage: ErrorCode.InsufficientStorage;
			case LoopDetected: ErrorCode.LoopDetected;
			default: InternalError;
		}
	}
}
