typedef Maybe<T> = kit.Maybe<T>;
typedef Result<T, E = Error> = kit.Result<T, E>;
typedef Lazy<T> = kit.Lazy<T>;
typedef Cancellable = kit.Cancellable;
typedef CancellableLink = kit.Cancellable.CancellableLink;
typedef Task<T, E = Error> = kit.Task<T, E>;
typedef Future<T> = kit.Future<T>;
typedef Nothing = kit.Nothing;
typedef Error = kit.Error;
typedef UniqueId = kit.UniqueId;
typedef Iter = kit.Iter;
#if !macro
@:genericBuild(kit.internal.EventBuilder.build())
#end
class Event<Rest> {}
#if !macro
@:genericBuild(kit.internal.OrBuilder.build())
#end
interface Or<Rest> {}

/**
	Convert any nullable value into a kit.Maybe.
**/
inline function toMaybe<T>(value:Null<T>):Maybe<T> {
	return kit.Sugar.toMaybe(value);
}

/**
	Attempt to call the given handler. If an exception is thrown, it will
	be caught and converted into a `Result.Error`.
**/
function attempt<T>(handler):Result<T, haxe.Exception> {
	return kit.Sugar.attempt(handler);
}

@:deprecated('Use `attempt` instead')
function getResult<T>(handler:() -> T):Result<T, haxe.Exception> {
	return attempt(handler);
}

/**
	Deconstructs an expression.

	```haxe
	var something:kit.Maybe = Some('foo');
	something.extract(try Some(foo));
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

	If you're sure that you don't need to do this check, prefix the match
	expression with `try` (e.g. `something.extract(try Some(foo))`) to throw a 
	runtime exception when a match isn't found.

	You can also pass in an `if` expression that gives you a way to scope
	matched values (and optionally run an `else` branch if no matches are
	found):

	```haxe
	var foo:Maybe<String> = None;
	foo.extract(if (Some(value)) {
		trace(value); // does not run
	} else {
		trace('Runs');
	});
	```
**/
macro function extract(input, match) {
	return kit.sugar.Extract.createExtractExpr(input, match);
}

/**
	DEPRECATED: Use `extract` with an `if` expression instead
**/
@:deprecated('Use `extract` with an `if` expression instead')
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
