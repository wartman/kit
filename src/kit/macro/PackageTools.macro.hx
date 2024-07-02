package kit.macro;

import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.io.Path;
using sys.FileSystem;

function scanForClasses(pack:String, implementing:String):Array<TypePath> {
	var types:Array<TypePath> = [];
	var roots = Context.getClassPath();
	var packParts = pack.split('.');

	for (root in roots) {
		var dir = root.normalize();
		if (dir.exists()) {
			types = types.concat(scanForClassInDir(dir, packParts, implementing));
		}
	}

	return types;
}

function scanForClassInDir(root:String, pack:Array<String>, implementing:String):Array<TypePath> {
	var types:Array<TypePath> = [];
	var dir = Path.join([root].concat(pack));

	if (!dir.exists()) return types;

	for (file in dir.readDirectory()) if (file.extension() == 'hx') {
		var name = file.withoutExtension();
		if (name == 'import') continue;
		var type = Context.getType(pack.concat([name]).join('.'));
		if (Context.unify(type, Context.getType(implementing))) {
			types.push({
				pack: pack,
				name: name
			});
		}
	}

	return types;
}
