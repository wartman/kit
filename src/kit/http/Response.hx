package kit.http;

import haxe.io.Bytes;

class Response extends Message<Response> {
	public final status:StatusCode;

	public function new(status, headers, body) {
		super(headers, body);
		this.status = status;
	}

	public function withHeader(header:HeaderField):Response {
		return new Response(status, headers.with(header), body);
	}

	public function withBody(body:Bytes):Response {
		return new Response(status, headers, body);
	}
}
