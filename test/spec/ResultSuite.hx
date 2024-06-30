package spec;

class ResultSuite extends Suite {
	function execute() {
		describe('kit.Result<String>', () -> {
			it('can succeed or fail', () -> {
				// What exactly are we testing here.
				var result:Result<String, String> = Ok('Ok');
				result.extract(Ok(value = 'Failed'));
				value.should().be('Ok');
			});
			describe('.map', () -> {
				it('can be transformed using `map`', () -> {
					var result:Result<String, String> = Ok('Ok');
					result.map(value -> value + ' Ok').extract(Ok(value = 'Failed'));
					value.should().be('Ok Ok');
				});
				it('will ignore `map` if its in a failed state', () -> {
					var result:Result<String, String> = Error('Failed');
					result.map(value -> value + ' Ok').extract(try Error(message));
					message.should().be('Failed');
				});
			});
		});
	}
}
