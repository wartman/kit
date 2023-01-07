package spec.core;

class SugarSuite extends Suite {
	function execute() {
		describe('Given an object', () -> {
			it('can deconstruct it', () -> {
				var foo:{a:String, b:Int} = {a: 'a', b: 1};
				foo.extract({a: var a, b:var b});
				a.should().be('a');
				b.should().be(1);
			});
		});
		describe('Given an enum', () -> {
			it('can deconstruct it', () -> {
				var foo:Option<String> = Some('foo');
				foo.extract(Some(var actual));
				actual.should().be('foo');
			});
			it('can handle non-matches without throwing an exception', () -> {
				var foo:Option<String> = None;
				foo.extract(Some(var actual = 'foo'));
				actual.should().be('foo');
			});
		});
	}
}
