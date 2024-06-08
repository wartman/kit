package kit.http;

// @todo: We need to handle body better.
abstract class Message<R:Message<R>> {
	public final headers:Headers;
	public final body:Maybe<Body>;

	public function new(?headers, ?body:Body) {
		this.headers = headers == null ? new Headers() : headers;
		this.body = body == null ? None : Some(body);
	}

	abstract public function withHeader(header:HeaderField):R;

	abstract public function withBody(body:Body):R;
}
