package kit.spec;

import kit.spec.Outcome.SuiteOutcome;

final class Runner {
	public final events:Events = new Events();

	final suites:Array<Suite> = [];

	public function new() {}

	public function add(cls:Class<Suite>) {
		var suite = Type.createInstance(cls, [events]);
		suites.push(suite);
	}

	public function addReporter(reporter:Reporter) {
		return events.addReporter(reporter);
	}

	public function run():Task<Array<SuiteOutcome>> {
		return new Future(activate -> {
			Task.sequence(...suites.map(s -> s.run())).handle(result -> {
				switch result {
					case Ok(outcomes): events.onComplete.dispatch(new Outcome(outcomes));
					case Error(error): events.onFailure.dispatch(error);
				}
				activate(result);
			});
		}).eager();
	}
}
