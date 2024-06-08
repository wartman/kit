import kit.spec.*;
import kit.spec.reporter.*;

function main() {
	var reporter = new ConsoleReporter({
		title: 'Kit Tests',
		verbose: true,
		trackProgress: true
	});
	var runner = new Runner();
	runner.addReporter(reporter);

	runner.add(spec.FutureSuite);
	runner.add(spec.TaskSuite);
	runner.add(spec.StreamSuite);
	runner.add(spec.SugarSuite);
	runner.add(spec.LazySuite);
	runner.add(spec.EventSuite);
	runner.add(spec.ResultSuite);
	runner.add(spec.MaybeSuite);
	runner.add(spec.MacroSuite);
	runner.add(spec.HttpSuite);

	runner.run();
}
