import kit.test.*;
import kit.test.reporter.*;

function main():Void {
	var reporter = new ConsoleReporter({
		title: 'Kit Tests',
		verbose: true,
		trackProgress: true
	});
	var runner = new kit.test.Runner();
	var cancel = runner.addReporter(reporter);

	runner.add(spec.async.FutureSuite);
	runner.add(spec.async.TaskSuite);

	runner.add(spec.core.SugarSuite);
	runner.add(spec.core.LazySuite);

	runner.add(spec.event.EventSuite);

	runner.run();
}
