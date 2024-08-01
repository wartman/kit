package kit.test;

import kit.test.reporter.ConsoleReporter;
import kit.test.Outcome;

class Runner {
	public final events:Events = new Events();

	final suites:Array<Suite> = [];

	public static function fromDefaults(?title) {
		var runner = new Runner();
		runner.addReporter(new ConsoleReporter({
			title: title,
			verbose: true,
			trackProgress: true
		}));
		return runner;
	}

	public function new() {}

	public function add(cls:Class<Suite>) {
		var suite = Type.createInstance(cls, [events]);
		suites.push(suite);
		return this;
	}

	public function addReporter(reporter:Reporter) {
		return events.addReporter(reporter);
	}

	public inline function withReporter(reporter:Reporter) {
		addReporter(reporter);
		return this;
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
