package kit.core;

macro function extract(input, match) {
	return kit.core.sugar.Extract.createExtractExpr(input, match);
}
