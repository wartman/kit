package kit.core.sugar;

import haxe.macro.Expr;
import haxe.macro.Context;

function createPipe(exprs:Array<Expr>) {
	var first = exprs.shift();
	var body:Array<Expr> = [];
	var tmp = '__pipe';

	if (first == null) return macro null;

	body.push(macro var $tmp = $first);

	for (index => expr in exprs) switch expr.expr {
		case ECall(e, params):
			var slot:Null<Int> = null;
			for (index => param in params) switch param.expr {
				case EConst(CIdent('_')) if (slot == null):
					slot = index;
				case EConst(CIdent('_')):
					Context.error('Only one slot is allowed', param.pos);
				default:
			}
			if (slot == null) {
				Context.error('Slot required', expr.pos);
			}
			params[slot] = macro $i{tmp};
			tmp = '__pipe$index';
			body.push(macro var $tmp = $expr);
		case EFunction(kind, f):
			if (f.args.length != 1) {
				Context.error('Only functions with one argument are allowed here.', expr.pos);
			}
			var call = macro($expr)($i{tmp});
			tmp = '__pipe$index';
			body.push(macro var $tmp = $call);
		default:
			Context.error('Invalid expression', expr.pos);
	}

	trace(haxe.macro.ExprTools.toString(macro $b{body}));

	return macro {
		@:mergeBlock $b{body};
		$i{tmp};
	}
}
