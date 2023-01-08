package kit.core.sugar;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

private typedef Assignment = {
	final name:String;
	final pos:Position;
	final decl:Var;
}

private typedef ExtractedExpr = {
	final hasFallback:Bool;
	final decls:Array<Expr>;
	final assignments:Array<Expr>;
};

function createExtractExpr(input:Expr, match:Expr) {
	var pos = Context.currentPos();
	var extracted = extractAssignments(match);

	var ifNoMatch:Expr = if (extracted.hasFallback)
		macro null;
	else
		macro throw 'Could not match the given expression';

	return macro @:mergeBlock {
		var __target = $input;
		@:mergeBlock $b{extracted.decls};
		switch __target {
			case $match:
				$b{extracted.assignments};
			default:
				${ifNoMatch}
		}
		__target;
	}
}

function createIfExtractExpr(input:Expr, match:Expr, body:Expr, ?otherwise:Expr) {
	var pos = Context.currentPos();
	var extracted = extractAssignments(match);

	if (otherwise == null) otherwise = macro null;

	return macro {
		var __target = $input;
		switch __target {
			case $match:
				@:mergeBlock $b{extracted.decls};
				$b{extracted.assignments};
				${body};
			default:
				${otherwise};
		}
	}
}

private function extractAssignments(expr:Expr):ExtractedExpr {
	var hasFallback:Bool = true;
	var assignments:Array<Assignment> = [];

	function process(expr:Expr) {
		switch expr.expr {
			case EConst(CIdent('_')):
			case EVars([decl]):
				var name = decl.name;
				if (decl.expr == null) hasFallback = false;
				assignments.push({name: name, decl: decl, pos: expr.pos});
				expr.expr = EConst(CIdent('_$name'));
			default:
				expr.iter(process);
		}
	}

	process(expr);

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

	return {
		decls: decls,
		assignments: assignments,
		hasFallback: hasFallback
	};
}
