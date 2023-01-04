package kit.core.sugar;

import haxe.macro.Expr;

using haxe.macro.Tools;

function as(input:Expr, type:Expr) {
	var ct = type.toString().toComplex();
	return macro cast($input, $ct);
}
