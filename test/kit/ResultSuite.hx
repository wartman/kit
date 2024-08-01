package kit;

using kit.Testing;
using kit.Sugar;

class ResultSuite extends Suite {
	@:test
	function canBeTransformedUsingMap() {
		var result:Result<String, String> = Ok('Ok');
		result.map(value -> value + ' Ok').extract(Ok(value = 'Failed'));
		value.equals('Ok Ok');
	}

	@:test
	function willIgnoreMapIfInAFailedState() {
		var result:Result<String, String> = Error('Failed');
		result.map(value -> value + ' Ok').extract(try Error(message));
		message.equals('Failed');
	}
}
