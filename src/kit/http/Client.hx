package kit.http;

interface Client {
	public function request(req:Request):Task<Response>;
}
