package kit.sugar;

import haxe.macro.Expr;

using haxe.macro.Tools;

function createCast(input:Expr, type:Expr) {
	var ct = type.toString().toComplex();
	return macro try cast($input, $ct) catch (_) null;
}
