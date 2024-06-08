package fixture.http;

import kit.http.*;

using Kit;
using StringTools;

class HelloWorldMiddleware implements Middleware {
	public function new() {}

	public function apply(handler:Handler):Handler {
		return request -> {
			if (!request.url.path.startsWith('/hello')) return handler.process(request);
			var headers = new Headers(new HeaderField(ContentType, 'text/html'));
			var res = new Response(OK, headers, '<p>Hello ${request.url}</p>');
			return Future.immediate(res);
		};
	}
}
