package kit;

typedef Option<T> = kit.ds.Option<T>;
typedef Result<T> = kit.ds.Result<T>;
typedef Empty = kit.ds.Empty;
typedef Lazy<T> = kit.core.Lazy<T>;
typedef Cancellable = kit.core.Cancellable;
typedef CancellableLink = kit.core.Cancellable.CancellableLink;
typedef Task<T> = kit.async.Task<T>;
typedef Future<T> = kit.async.Future<T>;
#if !macro
@:genericBuild(kit.event.EventBuilder.build())
#end
class Event<Rest> {}

/**
	Deconstructs an expression.

	Note that there are a few ways in which this differs from a 
	pattern in a switch statement. Most importantly, you *must* prefix
	the items you are extracting with `var`. For example:

	```haxe
	var something:kit.ds.Option = Some('foo');
	something.extract(Some(var foo));
	trace(foo); // => "foo"
	```

	Note that an exception will be thrown if `extract` fails to match
	against the pattern you give it. You can avoid this problem
	by giving every extracted var a default value. For example, the
	following code will *not* throw an exception:

	```haxe
	var something:kit.ds.Option = None;
	something.extract(Some(var foo = 'default'));
	trace(foo); // => "default"
	```

	Unless you're sure a pattern will always match, the best practice will
	probably be to provide defaults.
**/
macro function extract(input, match) {
	return kit.core.sugar.Extract.createExtractExpr(input, match);
}

/**
	Deconstructs an expression and passes it to the give `body`, but *only*
	if the expression is matched.

	If the expression is not matched, you can optionally provide an `otherwise`
	expression that will be executed instead.

	```haxe
	var foo:Option<String> = None;
	foo.ifExtract(Some(var value), {
		trace(value); // does not run
	}, {
		trace('Runs');
	});
	```
**/
macro function ifExtract(input, match, body, ?otherwise) {
	return kit.core.sugar.Extract.createIfExtractExpr(input, match, body, otherwise);
}

/**
	Casts the given expression to the given type.
**/
macro function as(input, type) {
	return kit.core.sugar.Type.as(input, type);
}
