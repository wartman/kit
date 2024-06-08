package kit.http;

class Response extends Message<Response> {
	public final status:StatusCode;

	public function new(status, ?headers, body:Body) {
		super(headers, body);
		this.status = status;
	}

	public function withHeader(header:HeaderField):Response {
		return new Response(status, headers.with(header), body.unwrap());
	}

	public function withBody(body:Body):Response {
		return new Response(status, headers, body);
	}
}
