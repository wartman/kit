function main():Void {
	var runner = new medic.Runner();

	runner.add(new unit.async.TestFuture());

	runner.add(new unit.core.TestSugar());
	runner.add(new unit.core.TestLazy());

	runner.run();
}
