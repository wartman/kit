package kit;

using kit.Sugar;
using kit.Testing;

class SugarSuite extends Suite {
	@:test
	function itCanDeconstructObjects() {
		var foo:{a:String, b:Int} = {a: 'a', b: 1};
		foo.extract(try {a: a, b: b});
		a.equals('a');
		b.equals(1);
	}

	@:test
	function itCanDeconstructAnEnum() {
		var foo:Maybe<String> = Some('foo');
		foo.extract(try Some(actual));
		actual.equals('foo');
	}

	@:test
	function itCanHandleNonMatchesWithoutAnException() {
		var foo:Maybe<String> = None;
		foo.extract(Some(actual = 'foo'));
		actual.equals('foo');
	}

	@:test(expects = 1)
	function usesIfExprAsAGuardAndReturnsTrueOnAMatch() {
		var foo:Maybe<String> = Some('foo');
		foo.extract(if (Some(value)) value.equals('foo'));
	}

	@:test(expects = 1)
	function usesIfExprAsAGuardAndReturnsFalseOnAMiss() {
		var foo:Maybe<String> = None;
		foo.extract(if (Some(value)) {
			value.equals('foo');
		} else {
			foo.equals(None);
		});
	}

	@:test(expects = 2)
	function doesNotLeakScopes() {
		var foo:Maybe<String> = Some('foo');
		var value:String = 'bar';
		foo.extract(if (Some(value)) value.equals('foo'));
		value.equals('bar');
	}

	@:test(expects = 2)
	function pipeWorks() {
		function add(input:String, append:String) {
			return input + append;
		}

		var result = 'foo'.pipe(add(_, 'bar'), add('bin', _), add(_, 'bax'));
		result.equals('binfoobarbax');

		var result = 'foo'.pipe(add(_, 'bar'), str -> str + 'ok', add('ok', _));
		result.equals('okfoobarok');
	}
}
