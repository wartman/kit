package kit.http.adaptor;

import haxe.io.Bytes;
import haxe.Http;
import kit.ds.Result;
import kit.async.*;

using kit.core.Sugar;

class HaxeAdaptor implements Adaptor {
	public function new() {}

	public function fetch(request:Request):Task<Response> {
		return new Future<Result<Response>>(activate -> {
			var http = new Http(request.url.withoutQuery());
			var responseStatus:StatusCode = OK;

			for (key => value in request.url.query) {
				http.addParameter(key, value);
			}

			for (header in request.headers) {
				header.extract({name: var name, value:var value});
				http.addHeader(name, value);
			}

			http.onStatus = status -> {
				responseStatus = status;
			}
			http.onBytes = data -> {
				// @todo: figure out where to get headers from Haxe's bad impl.
				var headers = new Headers([]);
				activate(Success(new Response(responseStatus, headers, data)));
			}
			http.onError = msg -> {
				if (responseStatus == OK) {
					responseStatus = InternalServerError;
				}
				// @todo: More?
				activate(Failure(new HttpException(responseStatus, msg)));
			}

			http.request(switch request.method {
				// lol haxe http is bad huh
				case Post: true;
				default: false;
			});
		});
	}
}
