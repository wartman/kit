package spec;

enum abstract Errors(String) {
	final NotFoo = 'Expected Foo';
	final NotBar = 'Expected Bar';
}

enum OtherErrors {
	NotFound;
	TooLong(length:Int);
}

typedef ErrorList = Or<Errors, OtherErrors>;
typedef StringOrInt = Or<String, Int>;

class OrSuite extends Suite {
	function execute() {
		describe('blok.Or', () -> {
			it('creates an abstract that can merge many types', () -> {
				var err:ErrorList = Errors.NotFoo;
				err.unwrap().equals(Errors(NotFoo)).should().be(true);
			});
			it('works with primitive types', () -> {
				var data:Or<String, Int> = 'foo';
				data.unwrap().extract(try String(value));
				value.should().be('foo');

				data = 1;
				data.unwrap().extract(try Int(value));
				value.should().be(1);
			});
			it('creates the same type regardless of the order of type params -- for example, Or<String, Int> is the same as Or<Int, String>.', () -> {
				var a:Or<String, Int> = 'Foo';
				var b:Or<Int, String> = 'Foo';
				a.unwrap().equals(b.unwrap()).should().be(true);
			});
			it('works with Tasks', spec -> {
				spec.expect(1);

				function failToGetInt():Task<String, Int> {
					return Task.reject(1);
				}

				// It would be great for this to happen automatically,
				// but I don't think Haxe's type system can handle that.
				//
				// Still useful?
				function test():Task<String, StringOrInt> {
					return failToGetInt().mapError(StringOrInt.fromInt);
				}

				test().inspectError(error -> {
					error.unwrap().equals(Int(1)).should().be(true);
				}).recover(_ -> Future.immediate('Ok'));
			});
		});
	}
}
