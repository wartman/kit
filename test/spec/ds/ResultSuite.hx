package spec.ds;

import haxe.Exception;

class ResultSuite extends Suite {
	function execute() {
		describe('kit.ds.Result<String>', () -> {
			it('can succeed or fail', () -> {
				// What exactly are we testing here.
				var result:Result<String> = Success('Ok');
				result.extract(Success(var value = 'Failed'));
				value.should().be('Ok');
			});
			describe('.map', () -> {
				it('can be transformed using `map`', () -> {
					var result:Result<String> = Success('Ok');
					result.map(value -> value + ' Ok').extract(Success(var value = 'Failed'));
					value.should().be('Ok Ok');
				});
				it('will ignore `map` if its in a failed state', () -> {
					var result:Result<String> = Failure(new Exception('Failed'));
					result.map(value -> value + ' Ok').extract(Failure(var exception));
					exception.message.should().be('Failed');
				});
			});
		});
	}
}
