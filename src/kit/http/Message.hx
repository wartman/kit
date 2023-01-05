package kit.http;

import haxe.io.Bytes;

abstract class Message<R:Message<R>> {
	public final headers:Headers;
	public final body:Bytes;

	public function new(headers, body) {
		this.headers = headers;
		this.body = body;
	}

	abstract public function withHeader(header:HeaderField):R;

	abstract public function withBody(body:Bytes):R;
}
