package kit.core.sugar;

import haxe.macro.Expr;
import haxe.macro.Context;

function createPipe(exprs:Array<Expr>) {
	var body = exprs.shift();

	if (body == null) return macro null;

	for (expr in exprs) switch expr.expr {
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
			params[slot] = macro $body;
			body = expr;
		case EFunction(kind, f):
			if (f.args.length != 1) {
				Context.error('Only functions with one argument are allowed here.', expr.pos);
			}
			body = macro($expr)($body);
		default:
			Context.error('Invalid expression', expr.pos);
	}

	return body;
}
