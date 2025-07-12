package kit.macro2;

import haxe.macro.Expr;

using Kit;
using Lambda;
using kit.macro2.Tools;

@:forward
abstract MetadataCollection(Metadata) {
	public inline function new(meta) {
		this = meta;
	}

	public inline function get(name:String):Maybe<MetadataEntry> {
		return this.maybeFind(entry -> entry.name == name);
	}

	public function options(name:String, ?allowed:Array<String>) {
		return switch get(name) {
			case Some(metadata):
				function validate(name:String, pos:Position) {
					if (allowed == null) return;
					if (!allowed.contains(name)) pos.error('Invalid option');
				}

				var entires:Map<String, Expr> = [];

				for (expr in metadata.params) switch expr {
					case macro $nameExpr = $expr:
						var name = switch nameExpr.expr {
							case EConst(CIdent(s)) | EConst(CString(s, _)): s;
							default: nameExpr.pos.error('Expected an identifier or a string');
						}
						validate(name, nameExpr.pos);
						entires.set(name, expr);
					default:
						expr.pos.error('Invalid expression');
				}

				Some(entires);
			case None:
				None;
		}
	}
}
