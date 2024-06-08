package spec;

import fixture.http.*;
import kit.http.*;
import kit.http.server.MockServer;

class HttpSuite extends Suite {
	function execute() {
		describe('hit.http.Server', () -> {
			var handler = new Handler(request -> new Future(activate -> {
				var headers = new Headers({name: ContentType, value: 'text/html'});
				var res = new Response(NotFound, headers, '<p>Not Found</p>');
				activate(res);
			})).into(new HelloWorldMiddleware());

			it('can serve HTTP or HTTP-like things', spec -> {
				spec.expect(2);

				var server = new MockServer(new Request(Get, '/hello'), response -> {
					response.status.should().be(OK);
					response.body.inspect(value -> {
						value.toBytes().toString().should().be('<p>Hello /hello</p>');
					}).orThrow();
				});

				server.serve(handler);
			});
			it('can fallback through middleware', spec -> {
				spec.expect(2);

				var server = new MockServer(new Request(Get, '/other'), response -> {
					response.status.should().be(NotFound);
					response.body.inspect(value -> {
						value.toBytes().toString().should().be('<p>Not Found</p>');
					}).orThrow();
				});

				server.serve(handler);
			});
		});
	}
}
