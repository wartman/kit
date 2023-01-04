package kit;

typedef Option<T> = kit.ds.Option<T>;
typedef Result<T> = kit.ds.Result<T>;
typedef Lazy<T> = kit.core.Lazy<T>;
typedef Task<T> = kit.async.Task<T>;
typedef Future<T> = kit.async.Future<T>;
typedef Empty = kit.core.Empty;
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
	Casts the given expression to the given type.
**/
macro function as(input, type) {
	return kit.core.sugar.Type.as(input, type);
}
