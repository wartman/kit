package kit.test;

import kit.async.Task;

final class Runner {
	public final events:Events = new Events();

	final suites:Array<Suite> = [];

	public function new() {}

	// @todo: make this a macro?
	public function add(cls:Class<Suite>) {
		var suite = Type.createInstance(cls, [events]);
		suites.push(suite);
	}

	public function addReporter(reporter:Reporter) {
		return events.addReporter(reporter);
	}

	public function run() {
		Task.sequence(...suites.map(s -> s.run())).handle(result -> switch result {
			case Success(results): events.onComplete.dispatch(new Result(results));
			case Failure(exception): events.onFailure.dispatch(exception);
		});
	}
}
