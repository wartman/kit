package kit.http.adaptor;

import kit.async.*;

using kit.core.Sugar;

class NodeAdaptor implements Adaptor {
	public function new() {}

	public function fetch(request:Request):Task<Response> {
		throw new haxe.exceptions.NotImplementedException();
	}
}
