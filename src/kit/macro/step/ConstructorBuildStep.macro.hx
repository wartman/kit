package kit.macro.step;

import haxe.macro.Expr;
import kit.macro.Hook;

using haxe.macro.Tools;
using kit.macro.Tools;

typedef ConstructorBuildStepOptions = {
	public final ?hook:HookName;
	public final ?lateHook:HookName;
	public final ?privateConstructor:Bool;
	public final ?customParser:(options:{
		builder:ClassBuilder,
		props:ComplexType,
		previousExpr:Maybe<Expr>,
		inits:Expr,
		lateInits:Expr
	}) -> Function;
}

class ConstructorBuildStep implements BuildStep {
	public final priority:Priority = Late;

	final options:ConstructorBuildStepOptions;

	public function new(?options) {
		this.options = options ?? {};
	}

	public function apply(builder:ClassBuilder) {
		var init = builder.hook(options.hook ?? Init);
		var late = builder.hook(options.lateHook ?? LateInit);
		var props = init.getProps().concat(late.getProps());
		var propsType:ComplexType = TAnonymous(props);
		var currentConstructor = builder.findField('new');
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
				(macro function(props:$propsType) {
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
					builder: builder,
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
				builder.addField({
					name: 'new',
					access: if (options.privateConstructor) [APrivate] else [APublic],
					kind: FFun(func),
					pos: (macro null).pos
				});
		}
	}
}
