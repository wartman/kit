package kit.core;

macro function extract(input, match) {
	return kit.core.sugar.Extract.createExtractExpr(input, match);
}

macro function as(input, type) {
	return kit.core.sugar.Type.as(input, type);
}
