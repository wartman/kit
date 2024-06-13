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

class OrSuite extends Suite {
	function execute() {
		describe('blok.Or', () -> {
			it('creates an abstract that can merge many types', () -> {
				var err:ErrorList = Errors.NotFoo;
				err.unwrap().equals(Errors(NotFoo)).should().be(true);
			});
			it('Works with primitive types', () -> {
				var data:Or<String, Int> = 'foo';
				data.unwrap().extract(String(value));
				value.should().be('foo');

				data = 1;
				data.unwrap().extract(Int(value));
				value.should().be(1);
			});
			it('Works with Tasks', spec -> {
				spec.expect(1);

				function failToGetInt():Task<String, Int> {
					return Task.reject(1);
				}

				// It would be great for this to happen automatically,
				// but I don't think Haxe's type system can handle that.
				//
				// Still useful?
				function test():Task<String, Or<String, Int>> {
					return failToGetInt().mapError(err -> (err : Or<String, Int>));
				}

				test().inspectError(error -> {
					error.unwrap().match(Int(1)).should().be(true);
				}).recover(_ -> Future.immediate('Ok'));
			});
		});
	}
}
