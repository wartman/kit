package kit.core.sugar;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

private typedef Assignment = {
	final name:String;
	final pos:Position;
	final decl:Var;
}

function createExtractExpr(input:Expr, match:Expr) {
	var pos = Context.currentPos();
	var assignments:Array<Assignment> = [];
	var hasFallback:Bool = true;

	function extractAssignment(expr:Expr) {
		switch expr.expr {
			case EConst(CIdent('_')):
			case EVars([decl]):
				var name = decl.name;
				if (decl.expr == null) hasFallback = false;
				assignments.push({name: name, decl: decl, pos: expr.pos});
				expr.expr = EConst(CIdent('_$name'));
			default:
				expr.iter(extractAssignment);
		}
	}

	extractAssignment(match);

	var decls = [
		for (assignment in assignments) {
			({
				expr: EVars([assignment.decl]),
				pos: assignment.pos
			} : Expr);
		}
	].filter(e -> e != null);
	var assignments:Array<Expr> = [
		for (assignment in assignments) {
			var name = assignment.name;
			macro @:pos(assignment.pos) $i{name} = $i{'_$name'};
		}
	];
	var ifNoMatch:Expr = if (hasFallback)
		macro null;
	else
		macro throw 'Could not match the given expression';

	return macro @:mergeBlock @:pos(pos) {
		var __target = $input;
		@:mergeBlock $b{decls};
		switch __target {
			case $match:
				$b{assignments};
			default:
				${ifNoMatch}
		}
		__target;
	}
}
