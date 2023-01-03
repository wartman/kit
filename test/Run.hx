using kit.Api;

function main():Void {
	var foo:Task<String> = 'foo';
	foo.next(foo -> foo + 'bar').handle(o -> {
		o.extract(Success(var foobar = 'default'));
		trace(foobar);
	});
	var test = new Foo('one', 1);
	test.extract({one: var one = 'nope', two:1});
	trace(one);
	test.extract({one: var other, two:var two});
	trace(other);
	trace(two);
}

class Foo {
	public final one:String;
	public final two:Int;

	public function new(one:String, two:Int) {
		this.one = one;
		this.two = two;
	}
}
