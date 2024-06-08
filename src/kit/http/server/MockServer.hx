package kit.http.server;

import kit.http.Server;

class MockServer implements Server {
	final request:Request;
	final onResponse:(response:Response) -> Void;

	public function new(request, onResponse) {
		this.request = request;
		this.onResponse = onResponse;
	}

	public function serve(handler:Handler):Future<ServerStatus> {
		return new Future(activate -> {
			handler.process(request).handle(response -> {
				onResponse(response);
				// This is a bit weird, but it does let us use MockServer in Specs.
				activate(Running(_ -> {
					throw 'Mock servers cannot be shut down';
				}));
			});
		});
	}
}
