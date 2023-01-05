import unit.http.adaptor.TestHaxeAdaptor;

function main():Void {
	var runner = new medic.Runner();

	runner.add(new unit.async.TestFuture());
	runner.add(new unit.async.TestTask());

	runner.add(new unit.core.TestSugar());
	runner.add(new unit.core.TestLazy());

	runner.add(new unit.event.TestEvent());

	runner.add(new unit.http.TestUrl());
	runner.add(new unit.http.adaptor.TestHaxeAdaptor());

	runner.run();
}
