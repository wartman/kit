package kit.macro2;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.Tools;

@:forward
abstract ExprBuilder(Expr) from Expr {
	@:from public inline static function of(expr) {
		return new ExprBuilder(expr);
	}

	public inline function new(expr) {
		this = expr;
	}

	public function at(pos:Position) {
		this.pos = pos;
		return abstract;
	}

	public function replace(expr:ExprDef) {
		this.expr = expr;
		return abstract;
	}

	public inline function error(message:String) {
		return Context.error(message, this.pos);
	}

	public function extractFunction():Function {
		return switch this.expr {
			case EFunction(_, f): f;
			default: error('Expected a function');
		}
	}

	public function extractValue():Dynamic {
		return this.getValue();
	}

	function extractString():String {
		return switch this.expr {
			case EConst(CString(s, _)): s;
			default: error('Expected a string');
		}
	}

	function extractInt():Int {
		return switch this.expr {
			case EConst(CInt(i)): Std.parseInt(i);
			default: error('Expected a string');
		}
	}

	@:to public function unwrap():Expr {
		return this;
	}

	@:to public function toString():String {
		return this.toString();
	}
}
