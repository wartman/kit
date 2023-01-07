package kit.spec;

import kit.spec.Result;
import kit.spec.Spec;
import kit.async.Task;
import kit.ds.Option;

using Type;
using kit.core.Sugar;

abstract class Suite {
	final events:Events;
	final suites:Array<SuiteSection> = [];
	var currentSuite:Option<SuiteSection> = None;

	final public function new(events) {
		this.events = events;
	}

	abstract function execute():Void;

	public function run() {
		execute();
		return Task.sequence(...suites.map(s -> s.run())).next(results -> new SuiteResult(this.getClass().getClassName(), [], results));
	}

	function describe(description:String, specs:() -> Void) {
		var previous = currentSuite;
		var suite = new SuiteSection(description, events);
		currentSuite = Some(suite);

		switch previous {
			case Some(parent):
				parent.addChild(suite);
			case None:
				suites.push(suite);
		}

		specs();
		currentSuite = previous;
	}

	function it(description:String, ?body:SpecBody) {
		switch currentSuite {
			case Some(suite):
				suite.addSpec(new Spec(events, description, body));
			case None:
				throw 'Cannot use `it` outside of a suite';
		}
	}
}

class SuiteSection {
	final description:String;
	final events:Events;
	final children:Array<SuiteSection> = [];
	final specs:Array<Spec> = [];

	public function new(description, events) {
		this.description = description;
		this.events = events;
	}

	public function addSpec(spec:Spec) {
		specs.push(spec);
	}

	public function addChild(child:SuiteSection) {
		children.push(child);
	}

	public function run():Task<SuiteResult> {
		return Task.sequence(...specs.map(spec -> spec.run())).next(specResults -> Task.sequence(...children.map(s -> s.run())).next(childrenResults -> {
			var result = new SuiteResult(description, specResults, childrenResults);
			events.onSuiteComplete.dispatch(result);
			result;
		}));
	}
}
