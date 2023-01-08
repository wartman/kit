import kit.spec.*;
import kit.spec.reporter.*;

function main():Void {
	var reporter = new ConsoleReporter({
		title: 'Kit Tests',
		verbose: true,
		trackProgress: true
	});
	var runner = new Runner();
	var cancel = runner.addReporter(reporter);

	runner.add(spec.async.FutureSuite);
	runner.add(spec.async.TaskSuite);

	runner.add(spec.core.SugarSuite);
	runner.add(spec.core.LazySuite);

	runner.add(spec.event.EventSuite);

	runner.add(spec.ds.ResultSuite);

	runner.run();
}
