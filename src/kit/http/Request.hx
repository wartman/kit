package kit.http;

import haxe.io.Bytes;

// @todo: how to handle credentials and stuff?
class Request extends Message<Request> {
	static final emptyBody = Bytes.ofString('');

	public static function ofUrl(url:Url) {
		return new Request(Get, url, new Headers([]));
	}

	public final url:Url;
	public final method:Method;

	public function new(method, url, headers, ?body) {
		super(headers, body == null ? emptyBody : body);
		this.method = method;
		this.url = url;
	}

	public function withHeader(header:HeaderField):Request {
		return new Request(method, url, headers.with(header), body);
	}

	public function withBody(body:Bytes):Request {
		return new Request(method, url, headers, body);
	}

	public function withUrl(url:Url):Request {
		return new Request(method, url, headers, body);
	}

	public function withMethod(method:Method) {
		return new Request(method, url, headers, body);
	}
}
