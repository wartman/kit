package kit.http;

enum abstract HeaderName(String) to String {
	final Referer = 'referer';
	final Host = 'host';
	final SetCookie = 'set-cookie';
	final Cookie = 'cookie';
	final ContentType = 'content-type';
	final ContentLength = 'content-length';
	final ContentDisposition = 'content-disposition';
	final ContentRange = 'content-range';
	final Accept = 'accept';
	final AcceptEncoding = 'accept-encoding';
	final TransferEncoding = 'transfer-encoding';
	final Range = 'range';
	final Location = 'location';
	final Authorization = 'authorization';
	final Origin = 'origin';
	final Vary = 'finaly';
	final CacheControl = 'cache-control';
	final Expires = 'expires';
	final AccessControlRequestMethod = 'access-control-request-method';
	final AccessControlRequestHeaders = 'access-control-request-headers';
	final AccessControlAllowOrigin = 'access-control-allow-origin';
	final AccessControlAllowCredentials = 'access-control-allow-credentials';
	final AccessControlExposeHeaders = 'access-control-expose-headers';
	final AccessControlMaxAge = 'access-control-max-age';
	final AccessControlAllowMethods = 'access-control-allow-methods';
	final AccessControlAllowHeaders = 'access-control-allow-headers';
	final UserAgent = 'user-agent';

	inline function new(s) this = s;

	@:from static inline function ofString(s:String) {
		return new HeaderName(s.toLowerCase());
	}
}
