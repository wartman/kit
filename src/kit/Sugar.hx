package kit;

macro function extract(input, match) {
	return kit.sugar.Extract.createExtractExpr(input, match);
}

macro function ifExtract(input, match, body, ?otherwise) {
	return kit.sugar.Extract.createIfExtractExpr(input, match, body, otherwise);
}

macro function as(input, type) {
	return kit.sugar.Type.createCast(input, type);
}

macro function pipe(...exprs) {
	return kit.sugar.Pipe.createPipe(exprs.toArray());
}
