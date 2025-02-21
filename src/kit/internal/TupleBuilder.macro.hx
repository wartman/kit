package kit.internal;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import kit.macro.*;

using haxe.macro.Tools;
using kit.macro.Tools;

function build() {
	return switch Context.getLocalType() {
		case TInst(_, params):
			buildTuple(params);
		default:
			throw 'assert';
	}
}

private function buildTuple(params:Array<Type>) {
	var paramLength = params.length;
	var pack = ['kit'];
	var name = 'Tuple_${paramLength}';
	var path:TypePath = {
		pack: pack,
		name: name,
		params: [for (t in params) TPType(t.toComplexType())]
	};
	var type = TPath(path);

	if (path.typePathExists()) {
		return type;
	}

	var builder = new ClassFieldCollection([]);
	var typeParams:Array<TypeParamDecl> = [];
	var arguments:Array<FunctionArg> = [];
	var fields:Array<Field> = [];
	var objectFields:Array<ObjectField> = [];

	for (index => _ in params) {
		var name = '_$index';
		var ct = TPath({name: 'T$index', pack: []});

		typeParams.push({name: 'T$index'});
		arguments.push({name: name, type: ct});

		fields.push({
			name: name,
			kind: FVar(ct),
			pos: (macro null).pos
		});

		objectFields.push({
			field: name,
			expr: macro $i{name}
		});
	}

	var expr:Expr = {
		expr: EObjectDecl(objectFields),
		pos: (macro null).pos
	}

	builder.addField({
		name: 'new',
		access: [APublic, AInline],
		kind: FFun({
			args: arguments,
			ret: macro :Void,
			expr: macro this = ${expr}
		}),
		pos: (macro null).pos,
	});

	if (paramLength == 0) {
		// Note: This line expects the `src/kit/Tuple_0.macro.hx` file to exist.
		// This is a pretty clumsy way to do things, so hopefully we'll come up
		// with something better.
		builder.add(macro class {
			public static macro function of(...exprs);
		});
	}

	Context.defineType({
		pack: pack,
		name: name,
		params: typeParams,
		meta: [{name: ':forward', params: [], pos: (macro null).pos}],
		kind: TDAbstract(TAnonymous(fields)),
		fields: builder.export(),
		pos: (macro null).pos
	});

	return type;
}

function fromExprs(...exprs:Expr) {
	var exprs = exprs.toArray();
	var params = exprs.map(e -> Context.typeof(e).toComplexType());
	var path:TypePath = {name: 'Tuple', pack: ['kit'], params: params.map(ct -> TPType(ct))};
	return macro new $path($a{exprs});
}
