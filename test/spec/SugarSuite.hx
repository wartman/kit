package spec;

class SugarSuite extends Suite {
	function execute() {
		describe('kit.core.Sugar', () -> {
			describe('*.extract', () -> {
				describe('Given an object', () -> {
					it('can deconstruct it', () -> {
						var foo:{a:String, b:Int} = {a: 'a', b: 1};
						foo.extract(try {a: a, b: b});
						a.should().be('a');
						b.should().be(1);
					});
				});
				describe('Given an enum', () -> {
					it('can deconstruct it', () -> {
						var foo:Maybe<String> = Some('foo');
						foo.extract(try Some(actual));
						actual.should().be('foo');
					});
					it('can handle non-matches without throwing an exception', () -> {
						var foo:Maybe<String> = None;
						foo.extract(Some(actual = 'foo'));
						actual.should().be('foo');
					});
				});
				describe('Given an if expr', () -> {
					it('returns true if it matches', spec -> {
						spec.expect(1);
						var foo:Maybe<String> = Some('foo');
						foo.extract(if (Some(value)) value.should().be('foo'));
					});
					it('returns false if it does not match', spec -> {
						spec.expect(1);
						var foo:Maybe<String> = None;
						foo.extract(if (Some(value)) {
							value.should().be('foo');
						} else {
							foo.should().be(None);
						});
					});
					it('does not leak into the parent scope', spec -> {
						spec.expect(2);
						var foo:Maybe<String> = Some('foo');
						var value:String = 'bar';
						foo.extract(if (Some(value)) value.should().be('foo'));
						value.should().be('bar');
					});
				});
			});

			describe('*.pipe', () -> {
				function add(input:String, append:String) {
					return input + append;
				}

				describe('Given a list of function calls', () -> {
					it('will pipe them', () -> {
						var result = 'foo'.pipe(add(_, 'bar'), add('bin', _), add(_, 'bax'));
						result.should().be('binfoobarbax');
					});
				});
				describe('Given a lambda or function with one argument', () -> {
					it('will call it', () -> {
						var result = 'foo'.pipe(add(_, 'bar'), str -> str + 'ok', add('ok', _));
						result.should().be('okfoobarok');
					});
				});
			});
		});
	}
}
