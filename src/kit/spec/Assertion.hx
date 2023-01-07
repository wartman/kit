package kit.spec;

import haxe.PosInfos;

enum Assertion {
	Pass;
	Fail(reason:String, ?pos:PosInfos);
	Warn(message:String);
}
