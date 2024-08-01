function main() {
	kit.test.Runner.fromDefaults()
		.add(kit.EventSuite)
		.add(kit.FutureSuite)
		.add(kit.LazySuite)
		.add(kit.MacroSuite)
		.add(kit.MaybeSuite)
		.add(kit.OrSuite)
		.add(kit.ResultSuite)
		.add(kit.StreamSuite)
		.add(kit.SugarSuite)
		.add(kit.TaskSuite)
		.run();
}
