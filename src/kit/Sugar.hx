package kit;

import haxe.Exception;

function toMaybe<T>(value:Null<T>):Maybe<T> {
	return switch value {
		case null: None;
		case value: Some(value);
	}
}

function attempt<T>(handler:() -> T):Result<T, Exception> {
	return try {
		Ok(handler());
	} catch (e) {
		Error(e);
	}
}

@:deprecated('Use `attempt` instead')
function getResult<T>(handler:() -> T):Result<T, Exception> {
	return attempt(handler);
}

macro function extract(input, match) {
	return kit.sugar.Extract.createExtractExpr(input, match);
}

@:deprecated
macro function ifExtract(input, match, body, ?otherwise) {
	return kit.sugar.Extract.createIfExtractExpr(input, match, body, otherwise);
}

macro function as(input, type) {
	return kit.sugar.Type.createCast(input, type);
}

macro function pipe(...exprs) {
	return kit.sugar.Pipe.createPipe(exprs.toArray());
}
