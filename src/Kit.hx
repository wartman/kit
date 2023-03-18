@:noUsing typedef Maybe<T> = kit.Maybe<T>;
@:noUsing typedef Result<T, E> = kit.Result<T, E>;
@:noUsing typedef Lazy<T> = kit.Lazy<T>;
@:noUsing typedef Cancellable = kit.Cancellable;
@:noUsing typedef CancellableLink = kit.Cancellable.CancellableLink;
@:noUsing typedef Task<T> = kit.Task<T>;
@:noUsing typedef Future<T> = kit.Future<T>;
@:noUsing typedef Nothing = kit.Nothing;
@:noUsing typedef Error = kit.Error;
#if !macro
@:genericBuild(kit.internal.EventBuilder.build())
#end
@:noUsing class Event<Rest> {}

/**
	Convert any nullable value into a kit.Maybe.
**/
inline extern function toMaybe<T>(value:Null<T>):Maybe<T> {
	return kit.Sugar.toMaybe(value);
}

/**
	Deconstructs an expression.

	```haxe
	var something:kit.Maybe = Some('foo');
	something.extract(Some(foo));
	trace(foo); // => "foo"
	```

	Note that an exception will be thrown if `extract` fails to match
	against the pattern you give it. You can avoid this problem
	by giving every extracted var a default value. For example, the
	following code will *not* throw an exception:

	```haxe
	var something:kit.Maybe = None;
	something.extract(Some(foo = 'default'));
	trace(foo); // => "default"
	```

	Unless you're sure a pattern will always match, the best practice will
	probably be to provide defaults.
**/
macro function extract(input, match) {
	return kit.sugar.Extract.createExtractExpr(input, match);
}

/**
	Deconstructs an expression and passes it to the give `body`, but *only*
	if the expression is matched.

	If the expression is not matched, you can optionally provide an `otherwise`
	expression that will be executed instead.

	```haxe
	var foo:Maybe<String> = None;
	foo.ifExtract(Some(value), {
		trace(value); // does not run
	}, {
		trace('Runs');
	});
	```
**/
macro function ifExtract(input, match, body, ?otherwise) {
	return kit.sugar.Extract.createIfExtractExpr(input, match, body, otherwise);
}

/**
	Casts the given expression to the given type.
**/
macro function as(input, type) {
	return kit.sugar.Type.createCast(input, type);
}

/**
	Allows you to pipe a value through a chain of functions.

	@todo: A better description.
**/
macro function pipe(...exprs) {
	return kit.sugar.Pipe.createPipe(exprs.toArray());
}
