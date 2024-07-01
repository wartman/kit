# Kit

Basic stuff I often find myself using.

## Getting Started

Install Kit using [Lix](https://github.com/lix-pm/lix.client) or Haxelib (only available from github for now).

Lix:
```
lix install github:wartman/kit
```

Haxelib:
```
haxelib git kit https://github.com/wartman/kit
```

Then just include `-lib kit` in your HXML.

You can import nearly all of Kit's modules at once with `using Kit`, which is generally the recommended way to do things. To make it extremely convenient, consider adding `using Kit` to your [`import.hx` file](https://haxe.org/manual/type-system-import-defaults.html).

## Documentation

> Warning: this documentation is extremely incomplete.

### Sugar

Kit has a few macro static extension methods that add some missing features to Haxe. They can be accessed with `using kit.Sugar` or via `using Kit`.

Use `expression.extract(pattern)` to deconstruct an expression. For example:

```haxe
var something:kit.Maybe = Some('foo');
something.extract(try Some(foo));
trace(foo); // => "foo"
```

Note that we used `try` in the example above. This asserts that we're sure `foo` is going to yield a value and that we're OK with a potential runtime exception getting thrown if this isn't the case (if Haxe had an `assert` keyword we'd have used that here).

If we're *not* sure a value can be extracted, we have two other options. One is to give every match a default value. For example, the following code will *not* throw an exception:

```haxe
var something:kit.Maybe = None;
something.extract(Some(foo = 'default'));
trace(foo); // => "default"
```

You can alternatively pass an `if` expression for a little more safety. This will deconstruct an expression *only* if there is a match.

If the target expression is not matched, you can optionally provide an else branch that will be executed instead.

```haxe
var foo:Maybe<String> = None;
foo.extract(if (Some(value)) {
	trace(value); // does not run
} else {
	// otherwise...
	trace('Runs');
});
```

> Todo: Cover the rest.

### Maybe

`kit.Maybe` is almost exactly the same as `haxe.ds.Option`, with the difference that it has a number of convenience methods attached to it.

For example:

```haxe
var greeting:Maybe<String> = Some('hello');

// This will display "hello world":
trace(greeting.map(greeting -> greeting + ' world').or('goodbye world'));

var noGreeting:Maybe<String> = None;

// This will display "goodbye world":
trace(noGreeting.map(greeting -> greeting + ' world').or('goodbye world'));
```

### Result

`kit.Result` represents some result that might fail.

```haxe
function makeFoo(str:String):Result<String, String> {
	return switch str {
		case 'foo': Error('Already foo!');
		default: Ok('foo');
	}
}
```

### Or

The `kit.Or` type can be used to handle places where several different types can be expected. It's especially useful for doing things like accumulating error types or handling any situation that might return different types. For example:

```haxe
enum ParseError {
	InvalidChar;
	TooLong;
	NotImplemented;
}

function parse(input:String):Task<String, ParseError> {
  // do work here, or:
  return Task.reject(NotImplemented);
}

// Note: yeah this isn't too ergonomic with tasks yet. Thinking on how to make this better.
function parseFile(file:kit.file.File):Task<String, Or<FileError, ParseError>> {
	return file
		.read()
		.mapError(err -> (err: Or<FileError, ParseError>))
		.map(contents -> parse(contents).mapError(err -> (err: Or<FileError, ParseError>)));
}

function main() {
	someFileSystem.file('./foo.txt')
		.next(parseFile)
		.handle(result -> switch result {
			case Ok(parsed): // do something
			case Error(err): switch err {
				case OrFileError(errors): // do something
				case OrParseError(errors): switch errors {
					case InvalidChar: // do something
					case TooLong: // do something
					case NotImplemented: // do something
				}
			}
		})
}
```

### Spec

> Todo

### Macro

> Todo
