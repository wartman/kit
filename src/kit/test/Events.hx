package kit.test;

import haxe.Exception;
import kit.core.Cancellable;
import kit.test.Result;
import kit.event.Event;

final class Events {
	public final onAssertion = new Event<Assertion>();
	public final onSpecComplete = new Event<SpecResult>();
	public final onSuiteComplete = new Event<SuiteResult>();
	public final onComplete = new Event<Result>();
	public final onFailure = new Event<Exception>();

	public function new() {}

	public function addReporter(reporter:Reporter):Cancellable {
		return [onAssertion.add(reporter.progress), onComplete.add(reporter.report)];
	}
}
