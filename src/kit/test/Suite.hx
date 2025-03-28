package kit.test;

import kit.test.Outcome;

using Kit;

@:autoBuild(kit.test.SuiteBuilder.build())
abstract class Suite {
	final events:Events;

	final public function new(events) {
		this.events = events;
	}

	abstract function getDescription():String;

	abstract function getTests():Array<Test>;

	public function run():Task<SuiteOutcome> {
		return getTests()
			.map(test -> test.run())
			.inSequence()
			.next(outcomes -> {
				var outcome = new SuiteOutcome(getDescription(), outcomes);
				events.onSuiteComplete.dispatch(outcome);
				return outcome;
			});
	}
}
