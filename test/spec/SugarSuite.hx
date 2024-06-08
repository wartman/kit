package spec;

class SugarSuite extends Suite {
	function execute() {
		describe('kit.core.Sugar', () -> {
			describe('*.extract', () -> {
				describe('Given an object', () -> {
					it('can deconstruct it', () -> {
						var foo:{a:String, b:Int} = {a: 'a', b: 1};
						foo.extract({a: a, b: b});
						a.should().be('a');
						b.should().be(1);
					});
				});
				describe('Given an enum', () -> {
					it('can deconstruct it', () -> {
						var foo:Maybe<String> = Some('foo');
						foo.extract(Some(actual));
						actual.should().be('foo');
					});
					it('can handle non-matches without throwing an exception', () -> {
						var foo:Maybe<String> = None;
						foo.extract(Some(actual = 'foo'));
						actual.should().be('foo');
					});
				});
			});

			describe('*.ifExtract', () -> {
				describe('Given an enum', () -> {
					it('returns true if it matches', (spec:Spec) -> {
						spec.expect(1);
						var foo:Maybe<String> = Some('foo');
						foo.ifExtract(Some(var value), value.should().be('foo'));
					});
					it('returns false if it does not match', (spec:Spec) -> {
						spec.expect(1);
						var foo:Maybe<String> = None;
						foo.ifExtract(Some(var value), {
							value.should().be('foo');
						}, {
							foo.should().be(None);
						});
					});
					it('does not leak into the parent scope', (spec:Spec) -> {
						spec.expect(2);
						var foo:Maybe<String> = Some('foo');
						var value:String = 'bar';
						foo.ifExtract(Some(var value), value.should().be('foo'));
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
