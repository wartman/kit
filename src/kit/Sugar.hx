package kit;

@:deprecated('Just use Null')
function toMaybe<T>(value:Null<T>):Maybe<T> {
	return switch value {
		case null: None;
		case value: Some(value);
	}
}

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
