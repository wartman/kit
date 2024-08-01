package kit.test;

import kit.test.Outcome;

class Events {
	public final onAssertion = new Event<Assertion>();
	public final onTestComplete = new Event<TestOutcome>();
	public final onSuiteComplete = new Event<SuiteOutcome>();
	public final onComplete = new Event<Outcome>();
	public final onFailure = new Event<Error>();

	public function new() {}

	public function addReporter(reporter:Reporter):Cancellable {
		return [onAssertion.add(reporter.progress), onComplete.add(reporter.report)];
	}
}
