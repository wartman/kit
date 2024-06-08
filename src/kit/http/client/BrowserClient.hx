package kit.http.client;

import haxe.io.Bytes;
import js.Browser;
import js.lib.HaxeIterator;
import js.lib.Int8Array;

typedef BrowserClientOptions = {
	public final ?cache:js.html.RequestCache;
	public final ?credentials:js.html.RequestCredentials;
	public final ?mode:js.html.RequestMode;
	public final ?referrerPolicy:js.html.ReferrerPolicy;
}

class BrowserClient implements Client {
	final options:BrowserClientOptions;

	public function new(?options) {
		this.options = options ?? {};
	}

	public function request(req:Request):Task<Response> {
		return switch req.url.scheme {
			case 'http' | 'https':
				var headers = new js.html.Headers();
				for (header in req.headers) {
					headers.append(header.name, header.value);
				}

				return Task.ofJsPromise(Browser.self.fetch(req.url, {
					cache: options.cache,
					credentials: options.credentials,
					mode: options.mode,
					referrerPolicy: options.referrerPolicy,
					body: req.body.map(body -> new Int8Array(body.toBytes().getData())).unwrap(),
					headers: headers,
					method: req.method
				}).then(res -> {
					var headers = [
						for (entry in new HaxeIterator(res.headers.entries()))
							new HeaderField(entry[0], entry[1])
					];
					res.arrayBuffer().then(data -> new Response(res.status, headers, switch data {
						case null: null;
						case data: new Body(Bytes.ofData(data));
					}));
				}));
			default:
				new Error(BadRequest, 'Missing Scheme (expected http/https) in URL: ${req.url.toString()}');
		}
	}
}
