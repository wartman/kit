package kit.http;

import kit.async.*;

interface Adaptor {
	public function fetch(request:Request):Task<Response>;
}
