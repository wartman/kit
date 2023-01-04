package unit.async;

import haxe.Exception;
import kit.async.Task;

using Medic;
using kit.core.Sugar;

class TestTask implements TestCase {
	public function new() {}

	@:test('Tasks work')
	@:test.async
	function testSimple(done) {
		var foo:Task<String> = 'foo';
		foo.next(foo -> foo + 'bar').handle(result -> {
			result.extract(Success(var foo = 'failed'));
			foo.equals('foobar');
			done();
		});
	}

	@:test('Tasks can fail')
	@:test.async
	function testReturnException(done) {
		var foo:Task<String> = 'foo';
		foo.next(_ -> new Exception('expected')).handle(result -> {
			result.extract(Failure({message: var message = 'failed'}));
			message.equals('expected');
			done();
		});
	}
}
