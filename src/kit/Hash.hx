package kit;

import haxe.crypto.Md5;

function hash(str:String) {
	return Md5.encode(str);
}
