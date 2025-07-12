package kit.macro2;

import haxe.macro.Expr;

enum abstract BuildHookName(String) from String {
	final Init = 'init';
	final LateInit = 'init:late';
	// @todo: more?
}

typedef BuildHookProp = {
	public final name:String;
	public final type:ComplexType;
	public final ?doc:String;
	public final optional:Bool;
}

class BuildHook {
	public final name:BuildHookName;

	var exprs:Array<Expr> = [];
	var props:Array<Field> = [];

	public function new(name) {
		this.name = name;
	}

	public function addExpr(...newExprs:Expr) {
		exprs = exprs.concat(newExprs);
		return this;
	}

	public function addProp(...newProps:BuildHookProp) {
		var pos = (macro null).pos;
		var fields:Array<Field> = newProps.toArray().map(f -> ({
			name: f.name,
			kind: FVar(f.type),
			doc: f.doc,
			meta: f.optional ? [{name: ':optional', pos: pos}] : [],
			pos: pos
		} : Field));
		props = props.concat(fields);
		return this;
	}

	public function getExprs() {
		return exprs;
	}

	public function getProps() {
		return props;
	}
}
