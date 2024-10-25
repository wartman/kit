package kit;

@:using(kit.Result.ResultTools)
enum Result<T, E = Error> {
	Ok(value:T);
	Error(error:E);
}

class ResultTools {
	public static function isOk<T, E>(result:Result<T, E>):Bool {
		return switch result {
			case Ok(_): true;
			case Error(_): false;
		}
	}

	public static function isError<T, E>(result:Result<T, E>):Bool {
		return switch result {
			case Ok(_): false;
			case Error(_): true;
		}
	}

	public static function unwrap<T, E>(result:Result<T, E>):Null<T> {
		return switch result {
			case Ok(value): value;
			case Error(_): null;
		}
	}

	public static function map<T, E, R>(result:Result<T, E>, transform:(value:T) -> R):Result<R, E> {
		return switch result {
			case Ok(value): Ok(transform(value));
			case Error(error): Error(error);
		}
	}

	public static function flatMap<T, E, R>(result:Result<T, E>, transform:(value:T) -> Result<R, E>):Result<R, E> {
		return switch result {
			case Ok(value): transform(value);
			case Error(error): Error(error);
		}
	}

	public static function mapError<T, E, R>(result:Result<T, E>, transform:(e:E) -> R):Result<T, R> {
		return switch result {
			case Ok(value): Ok(value);
			case Error(error): Error(transform(error));
		}
	}

	public static function inspect<T, E>(result:Result<T, E>, inspector:(value:T) -> Void) {
		switch result {
			case Ok(value): inspector(value);
			default:
		}
		return result;
	}

	public static function inspectError<T, E>(result:Result<T, E>, inspector:(error:E) -> Void) {
		switch result {
			case Error(error): inspector(error);
			default:
		}
		return result;
	}

	public static function or<T, E>(result:Result<T, E>, value:Lazy<T>):T {
		return switch result {
			case Ok(value): value;
			case Error(_): value.get();
		}
	}

	public static macro function orReturn(result) {
		return macro @:pos(result.pos) switch ${result} {
			case Ok(value): value;
			case Error(error): return kit.Result.Error(error);
		}
	}

	public static function orThrow<T, E>(result:Result<T, E>, ?message:String):T {
		return switch result {
			case Ok(value): value;
			case Error(error) if (message == null): throw error;
			case Error(_): throw message;
		};
	}

	public static function toMaybe<T, E>(result:Result<T, E>):Maybe<T> {
		return switch result {
			case Ok(value): Some(value);
			case Error(_): None;
		}
	}
}
