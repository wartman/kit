package kit.internal;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import kit.macro.*;

using haxe.macro.Tools;
using kit.macro.Tools;

function build() {
	return switch Context.getLocalType() {
		case TInst(_.get() => {name: 'Or'}, params):
			buildOr(params);
		default:
			throw 'assert';
	}
}

private function buildOr(params:Array<Type>) {
	var names = params.map(type -> type.stringifyTypeForClassName());

	names.sort((a, b) -> if (a < b) -1 else 1);

	var path:TypePath = {
		pack: ['kit'],
		name: 'Or__${names.join('__')}'
	};
	var ct:ComplexType = TPath(path);

	if (path.typePathExists()) {
		return ct;
	}

	var enumImpl:TypePath = {
		pack: ['kit'],
		name: path.name + '_Impl'
	}
	var enumImplCt:ComplexType = TPath(enumImpl);
	var enumBuilder = new ClassFieldCollection([]);
	var builder = new ClassFieldCollection([]);

	for (type in params) {
		var innerCt = type.toComplexType();
		var name = switch innerCt {
			case TPath(p) if (p.sub == null):
				p.name;
			case TPath(p):
				p.sub;
			default:
				Context.currentPos().error('Invalid type');
		}
		var constructorName = 'Or$name';
		var fromName = 'from$name';
		var toName = 'to$name';
		var tryName = 'try$name';
		var construct = enumImpl.typePathToArray().concat([constructorName]);
		var error = 'Current value is not a $name';

		enumBuilder.add(macro class {
			public static function $constructorName(value : $innerCt) {}
		});

		builder.add(macro class {
			@:from public inline static function $fromName(value : $innerCt):$ct {
				return $p{construct}(value);
			}

			public inline function $toName():kit.Maybe<$innerCt> {
				return switch this {
					case $i{constructorName}(value): Some(value);
					default: None;
				}
			}

			public inline function $tryName():$innerCt {
				return switch this {
					case $i{constructorName}(value): value;
					default: throw $v{error};
				}
			}
		});
	}

	builder.add(macro class {
		@:to public function unwrap():$enumImplCt {
			return this;
		}

		public function inspect(inspector:(value:$enumImplCt) -> Void) {
			inspector(unwrap());
			return abstract;
		}

		public function map<R>(transform:(value:$enumImplCt) -> R):R {
			return transform(unwrap());
		}
	});

	Context.defineType({
		name: enumImpl.name,
		pack: enumImpl.pack,
		kind: TDEnum,
		fields: enumBuilder.export(),
		pos: (macro null).pos
	});

	Context.defineType({
		name: path.name,
		pack: path.pack,
		kind: TDAbstract(enumImplCt, [], [enumImplCt]),
		fields: builder.export(),
		pos: (macro null).pos
	});

	return ct;
}
