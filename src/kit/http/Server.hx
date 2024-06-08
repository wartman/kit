package kit.http;

import haxe.Exception;

enum ServerStatus {
	Failed(e:Exception);
	Running(close:(handle:(status:Bool) -> Void) -> Void);
	Closed;
}

interface Server {
	public function serve(handler:Handler):Future<ServerStatus>;
}
