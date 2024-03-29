Kit
===

Basic stuff I often find myself using.

Getting Started
---------------

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

Documentation
-------------

> Warning: this documentation is extremely incomplete.

### Sugar

Kit has a few macro static extension methods that add some missing features to Haxe. They can be accessed with `using kit.Sugar` or via `using Kit`.

Use `expression.extract(pattern)` to deconstruct an expression. For example:

```haxe
var something:kit.Maybe = Some('foo');
something.extract(Some(foo));
trace(foo); // => "foo"
```

Note that an exception will be thrown if `extract` fails to match against the pattern you give it. You can avoid this problem by giving every match a default value. For example, the following code will *not* throw an exception:

```haxe
var something:kit.Maybe = None;
something.extract(Some(foo = 'default'));
trace(foo); // => "default"
```

Unless you're sure a pattern will always match, best practice is to provide defaults.

You can alternatively use `target.ifExtract(pattern, body, ?otherwise)` for a little more safety. This will deconstruct an expression and pass it to the given `body`, but *only* if the target expression is matched.

If the target expression is not matched, you can optionally provide an `otherwise` expression that will be executed instead.

```haxe
var foo:Maybe<String> = None;
foo.ifExtract(Some(value), {
  trace(value); // does not run
}, {
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

> Todo: Cover the rest.

Principals
----------

Kit is somewhat similar to Tink or Thx, but with one additional goal: the only package other Kit modules are allowed to rely on is this root kit module (and on `kit.spec` for testing).

