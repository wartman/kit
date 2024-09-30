package kit.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using Lambda;
using StringTools;
using haxe.macro.Tools;
using kit.Hash;

function at(expr:Expr, pos:Position) {
	return macro @:pos(pos) $expr;

}
function error(pos:Position, message:String) {
	return Context.error(message, pos);
}

function getMetadata(field:Field, name:String):Null<MetadataEntry> {
	return field.meta.find(m -> m.name == name);
}

function extractOptions(metadata:MetadataEntry, ?allowed:Array<String>) {
	function validate(name:String, pos:Position) {
		if (allowed == null) return;
		if (!allowed.contains(name)) error(pos, 'Invalid option');
	}

	var entires:Map<String, Expr> = [];

	for (expr in metadata.params) switch expr {
		case macro $nameExpr = $expr:
			var name = switch nameExpr.expr {
				case EConst(CIdent(s)) | EConst(CString(s, _)): s;
				default: error(nameExpr.pos, 'Expected an identifier or a string');
			}
			validate(name, nameExpr.pos);
			entires.set(name, expr);
		default:
			error(expr.pos, 'Invalid expression');
	}

	return entires;
}

function getField(t:TypeDefinition, name:String, ?pos:Position):Result<Field, haxe.macro.Expr.Error> {
	return switch t.fields.find(f -> f.name == name) {
		case null: Error(new haxe.macro.Expr.Error('Field $name was not found', pos ?? Context.currentPos()));
		case field: Ok(field);
	}
}

function toTypeParamDecl(params:Array<TypeParameter>) {
	return params.map(p -> ({
		name: p.name,
		constraints: extractTypeParams(p)
	} : TypeParamDecl));
}

function withPos(field:Field, position:Position) {
	field.pos = position;
	return field;
}

function applyParameters(field:Field, params:Array<TypeParamDecl>) {
	switch field.kind {
		case FFun(f):
			f.params = params;
		default:
			// todo
	}
	return field;
}

function typeExists(name:String) {
	try {
		return Context.getType(name) != null;
	} catch (e:String) {
		return false;
	}
}

function typePathExists(path:TypePath) {
	return typeExists(typePathToString(path));
}

function typePathToArray(path:TypePath) {
	return path.pack.concat([path.name, path.sub]).filter(s -> s != null);
}

function typePathToString(path:TypePath) {
	return typePathToArray(path).join('.');
}

function parseAsComplexType(name:String):ComplexType {
	return switch Context.parse('(null:${name})', Context.currentPos()) {
		case macro(null : $type): type;
		default: null;
	}
}

function resolveComplexType(expr:Expr):ComplexType {
	return switch expr.expr {
		case ECall(e, params):
			var tParams = params.map(param -> resolveComplexType(param).toString()).join(',');
			parseAsComplexType(resolveComplexType(e).toString() + '<' + tParams + '>');
		default:
			switch Context.typeof(expr) {
				case TType(_, _):
					parseAsComplexType(expr.toString());
				default:
					Context.error('Invalid expression', expr.pos);
					null;
			}
	}
}

function stringifyTypeForClassName(type:haxe.macro.Type):String {
	return switch type {
		// Attempt to use human-readable names if possible
		case TInst(_, []) | TEnum(_, []) | TAbstract(_, []):
			type.toString().replace('.', '_');
		case TInst(_.toString() => name, params) | TAbstract(_.toString() => name, params) | TEnum(_.toString() => name, params):
			name.replace('.', '_') + '__' + params.map(stringifyTypeForClassName).join('__');
		case TLazy(f):
			stringifyTypeForClassName(f());
		default:
			// Fallback to using a hash.
			type.toString().hash();
	}
}

function extractTypeParams(tp:TypeParameter) {
	return switch tp.t {
		case TInst(kind, _): switch kind.get().kind {
				case KTypeParameter(constraints): constraints.map(t -> t.toComplexType());
				default: [];
			}
		default: [];
	}
}

function extractFunction(e:Expr):Function {
	return switch e.expr {
		case EFunction(_, f): f;
		default: Context.error('Expected a function', e.pos);
	}
}

function extractString(e:Expr):String {
	return switch e.expr {
		case EConst(CString(s, _)): s;
		default: Context.error('Expected a string', e.pos);
	}
}

function extractInt(e:Expr):Int {
	return switch e.expr {
		case EConst(CInt(i)): Std.parseInt(i);
		default: Context.error('Expected a string', e.pos);
	}
}
