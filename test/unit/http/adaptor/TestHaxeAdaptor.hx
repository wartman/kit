package unit.http.adaptor;

import kit.http.*;
import kit.http.adaptor.HaxeAdaptor;

using Medic;
using haxe.Json;

class TestHaxeAdaptor implements TestCase {
	public function new() {}

	@:test('Simple request works')
	@:test.async(2000)
	function testRequest(done) {
		var adaptor = new HaxeAdaptor();
		adaptor.fetch(new Request(Get, 'https://httpbin.org/get?foo=foo', new Headers([{name: Accept, value: 'application/json'}]))).handle(res -> switch res {
			case Success(res):
				// @todo: Check response headers.
				res.status.equals(OK);
				// @todo: We need a better way to handle request bodies.
				var json:{foo:String} = res.body.toString().parse().args;
				json.foo.equals('foo');
				done();
			case Failure(exception):
				Assert.fail(exception.message);
				done();
		});
	}
}
