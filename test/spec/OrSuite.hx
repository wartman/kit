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
		});
	}
}
