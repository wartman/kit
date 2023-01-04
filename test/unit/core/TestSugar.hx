package unit.core;

import kit.ds.Option;

using Medic;
using kit.core.Sugar;

class TestSugar implements TestCase {
	public function new() {}

	@:test('Extract works on enums')
	function testSimpleEnum() {
		var foo:Option<String> = Some('foo');
		foo.extract(Some(var actual));
		actual.equals('foo');
	}

	@:test('Providing a default prevents exceptions from being thrown on extracted enums')
	function testProvideDefaultEnum() {
		var foo:Option<String> = None;
		foo.extract(Some(var actual = 'ok'));
		actual.equals('ok');
	}

	@:test('Extract works on objects')
	function testWorksOnObjects() {
		var foo:{a:String, b:Int} = {a: 'a', b: 1};
		foo.extract({a: var a, b:var b});
		a.equals('a');
		b.equals(1);
	}
}
