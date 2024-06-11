package kit.internal;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

using haxe.macro.Tools;
using kit.macro.Tools;

function build() {
	return switch Context.getLocalType() {
		case TInst(_.get() => {name: 'Event'}, params):
			buildEvent(params);
		default:
			throw 'assert';
	}
}

private function buildEvent(params:Array<Type>):ComplexType {
	params = params.filter(p -> p.toString() != 'Void');

	var paramLength = params.length;
	var pack = ['kit'];
	var name = 'Event_${paramLength}';
	var path:TypePath = {
		pack: pack,
		name: name,
		params: [for (t in params) TPType(t.toComplexType())]
	};
	var type = TPath(path);

	if (path.typePathExists()) {
		return type;
	}

	var typeParams:Array<TypeParamDecl> = [];
	var superClassFunctionArgs:Array<ComplexType> = [];
	var dispatchArgs:Array<FunctionArg> = [];
	var listenerCallParams:Array<Expr> = [];

	for (i in 0...paramLength) {
		typeParams.push({name: 'T$i'});
		superClassFunctionArgs.push(TPath({name: 'T$i', pack: []}));
		dispatchArgs.push({name: 'arg$i', type: TPath({name: 'T$i', pack: []})});
		listenerCallParams.push(macro $i{'arg$i'});
	}

	var pos = Context.currentPos();

	Context.defineType({
		pack: pack,
		name: name,
		pos: pos,
		params: typeParams,
		kind: TDClass({
			pack: pack,
			name: "Event",
			sub: "EventBase",
			params: [TPType(TFunction(superClassFunctionArgs, macro :Void))]
		}, [], false, true, false),
		fields: [
			{
				name: "dispatch",
				access: [APublic],
				pos: pos,
				kind: FFun({
					args: dispatchArgs,
					ret: macro :Void,
					expr: macro {
						startDispatch();
						var sub = head;
						while (sub != null) {
							sub.listener($a{listenerCallParams});
							if (sub.once) sub.cancel();
							sub = sub.next;
						}
						endDispatch();
					}
				})
			}
		]
	});

	return type;
}
