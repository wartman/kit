package kit.spec;

import kit.Cancellable;
import kit.spec.Outcome;

final class Events {
	public final onAssertion = new Event<Assertion>();
	public final onSpecComplete = new Event<SpecOutcome>();
	public final onSuiteComplete = new Event<SuiteOutcome>();
	public final onComplete = new Event<Outcome>();
	public final onFailure = new Event<Error>();

	public function new() {}

	public function addReporter(reporter:Reporter):Cancellable {
		return [onAssertion.add(reporter.progress), onComplete.add(reporter.report)];
	}
}
