package kit.http;

// @todo: How do we handle uploaded files?
class Request extends Message<Request> {
	public static function ofUrl(url:Url) {
		return new Request(Get, url);
	}

	public final url:Url;
	public final method:Method;

	public function new(method, url, ?headers, ?body) {
		super(headers, body);
		this.method = method;
		this.url = url;
	}

	public function withUrl(url:Url):Request {
		return new Request(method, url, headers, body.unwrap());
	}

	public function withHeader(header:HeaderField):Request {
		return new Request(method, url, headers.with(header), body.unwrap());
	}

	public function withBody(body:Body):Request {
		return new Request(method, url, headers, body);
	}

	public function withMethod(method:Method) {
		return new Request(method, url, headers, body.unwrap());
	}
}
