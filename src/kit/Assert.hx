package kit;

macro function assert(test, ?message) {
	if (haxe.macro.Context.defined('debug')) {
		return kit.internal.AssertionBuilder.buildAssertion(test, message);
	}
	return macro null;
}
