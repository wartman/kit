package kit.macro2;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

function at(expr:Expr, pos:Position) {
	var expr = macro @:pos(pos) $expr;
	return expr;
}

function error(pos:Position, message:String) {
	return Context.error(message, pos);
}
