package kit.http.client;

import haxe.Http;

class StdClient implements Client {
	public function new() {}

	public function request(req:Request):Task<Response> {
		return switch req.url.scheme {
			case 'http' | 'https':
				new Task(activate -> {
					var http = new Http('');
					var status:StatusCode = OK;
					var getHeaders = () -> new Headers(...[for (name => value in http.responseHeaders) new HeaderField(name, value)]);
					http.onStatus = code -> {
						status = code;
					}
					http.onBytes = data -> {
						var response = new Response(status, getHeaders(), data);
						activate(Ok(response));
					};
					http.onError = msg -> {
						status = status == OK ? InternalServerError : status;
						activate(Ok(new Response(status, getHeaders(), msg)));
					};
					http.request(req.method == Post);
				});
			default:
				new Error(BadRequest, 'Missing Scheme (expected http/https) in URL: ${req.url.toString()}');
		}
	}
}
