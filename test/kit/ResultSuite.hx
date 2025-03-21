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

	@:test(expects = 2)
	function alwaysMethodCanBeUsedToHelpWithChaining() {
		var result:Result<String, String> = Ok('ok');
		result.always(() -> Assert.pass());
		var result:Result<String, String> = Error('error');
		result.always(() -> Assert.pass());
	}

	@:test
	function canReturnIfErrored() {
		var result:Result<String, String> = Error('failed');
		var tester = () -> {
			var str = result.orReturn();
			return Ok(str);
		}
		tester().extract(try Error(message));
		message.equals('failed');
	}
}
