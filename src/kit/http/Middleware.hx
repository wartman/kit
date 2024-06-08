package kit.http;

interface Middleware {
	public function apply(handler:Handler):Handler;
}
