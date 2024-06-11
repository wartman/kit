package kit.internal;

import haxe.macro.Expr;

using haxe.macro.ExprTools;

function buildAssertion(test:ExprOf<Bool>, message:Expr) {
	switch message {
		case macro null:
			var str = 'Failed assertion: ' + test.toString();
			message = macro $v{str};
		default:
	}
	return macro if (!$test) throw new kit.AssertionException($message);
}
