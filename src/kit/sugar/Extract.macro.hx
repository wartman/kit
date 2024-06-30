package kit.sugar;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;
using kit.macro.Tools;

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

	return switch match.expr {
		case EIf(match, body, otherwise):
			var extracted = extractAssignments(match);
			if (otherwise == null) otherwise = macro null;

			macro {
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
		case ETry(expr, []):
			var extracted = extractAssignments(expr);

			var ifNoMatch:Expr = if (extracted.hasFallback)
				macro null;
			else
				macro throw 'Could not match the given expression';

			macro @:mergeBlock {
				var __target = $input;
				@:mergeBlock $b{extracted.decls};
				switch __target {
					case $expr:
						$b{extracted.assignments};
					default:
						${ifNoMatch}
				}
				__target;
			}
		case ETry(match, catches):
			catches[0].expr.pos.error('You cannot catch errors here');
			macro null;
		default:
			var extracted = extractAssignments(match);

			if (!extracted.hasFallback) {
				var str = match.toString();
				match.pos.error('Fallbacks required for all non-exhaustive values. To skip this check, prefix this match expression with `try` (e.g. `try ${str}`)');
			}

			macro @:mergeBlock {
				var __target = $input;
				@:mergeBlock $b{extracted.decls};
				switch __target {
					case $match:
						$b{extracted.assignments};
					default:
						null;
				}
				__target;
			}
	}
}

@:deprecated
function createIfExtractExpr(input:Expr, match:Expr, body:Expr, ?otherwise:Expr) {
	Context.warning('ifExtract is deprecated. Use `extract` with an if expression instead', input.pos);

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
			case ECall(_, params):
				// @todo: Are the other special cases we need to handle?
				for (param in params) process(param);
			case EConst(CIdent('_')):
			case EConst(CIdent(name)):
				hasFallback = false;
				assignments.push({
					name: name,
					decl: {name: name},
					pos: expr.pos
				});
				expr.expr = EConst(CIdent('_$name'));
			case EBinop(OpAssign, {
				expr: EConst(CIdent(name)),
				pos: pos
			}, e2):
				assignments.push({
					name: name,
					decl: {name: name, expr: e2},
					pos: pos
				});
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
