package kit.spec;

import haxe.macro.Expr;

using kit.macro.PackageTools;

class Runner {
	public static function addPackage(self:Expr, pack:String):Expr {
		var classes = pack.scanForClasses('kit.spec.Suite');
		var exprs = [
			for (type in classes) macro __runner.add($p{type.pack.concat([type.name, type.sub].filter(p -> p != null))})
		];

		return macro {
			var __runner = $self;
			@:mergeBlock $b{exprs};
			__runner;
		};
	}
}
