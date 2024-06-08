package kit.spec;

interface Reporter {
	public function progress(assertion:Assertion):Void;
	public function report(outcome:Outcome):Void;
}
