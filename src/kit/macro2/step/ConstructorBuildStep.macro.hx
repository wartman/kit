package kit.macro2.step;

import haxe.macro.Expr;
import kit.macro2.BuildHook;

using kit.macro2.Tools;

typedef ConstructorBuildStepOptions = {
	public final ?hook:BuildHookName;
	public final ?lateHook:BuildHookName;
	public final ?privateConstructor:Bool;
	public final ?customParser:(options:{
		build:Build,
		props:ComplexType,
		previousExpr:Maybe<Expr>,
		inits:Expr,
		lateInits:Expr
	}) -> Function;
}

class ConstructorBuildStep implements BuildStep {
	public final priority:BuildPriority = BuildLate;

	final options:ConstructorBuildStepOptions;

	public function new(?options) {
		this.options = options ?? {};
	}

	public function apply(build:Build) {
		var init = build.hook(options.hook ?? Init);
		var late = build.hook(options.lateHook ?? LateInit);
		var props = init.getProps().concat(late.getProps());
		var propsType:ComplexType = TAnonymous(props);
		var currentConstructor = build.fields.get('new');
		var previousConstructorExpr:Maybe<Expr> = switch currentConstructor {
			case Some(field): switch field.kind {
					case FFun(f):
						if (f.args.length > 0) {
							field.pos.error(
								'You cannot pass arguments to this constructor -- it can only '
								+ 'be used to run code at initialization.');
						}

						if (options.privateConstructor == true && field.access.contains(APublic)) {
							field.pos.error('Constructor must be private (remove the `public` keyword)');
						}

						Some(f.expr);
					default:
						throw 'assert';
				}
			case None:
				None;
		}
		var func:Function = switch options.customParser {
			case null:
				ExprBuilder.of(macro function(props:$propsType) {
					@:mergeBlock $b{init.getExprs()};
					@:mergeBlock $b{late.getExprs()};
					${
						switch previousConstructorExpr {
							case Some(expr): expr;
							case None: macro null;
						}
					}
				}).extractFunction();
			case custom:
				custom({
					build: build,
					props: propsType,
					previousExpr: previousConstructorExpr,
					inits: macro @:mergeBlock $b{init.getExprs()},
					lateInits: macro @:mergeBlock $b{late.getExprs()},
				});
		}

		switch currentConstructor {
			case Some(field):
				field.kind = FFun(func);
			case None:
				build.fields.addField({
					name: 'new',
					access: if (options.privateConstructor) [APrivate] else [APublic],
					kind: FFun(func),
					pos: (macro null).pos
				});
		}
	}
}
