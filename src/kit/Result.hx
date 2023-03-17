package kit;

@:using(kit.Result.ResultTools)
enum Result<T, E> {
	Ok(value:T);
	Error(error:E);
}

class ResultTools {
	public static function unwrap<T, E>(result:Result<T, E>):T {
		return switch result {
			case Ok(value): value;
			case Error(error): throw error;
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

	public static function or<T, E>(result:Result<T, E>, value:Lazy<T>):T {
		return switch result {
			case Ok(value): value;
			case Error(_): value.get();
		}
	}

	public static function orThrow<T, E>(result:Result<T, E>, ?message:String):T {
		return message == null ? unwrap(result) : switch result {
			case Ok(value): value;
			case Error(_): throw message;
		};
	}
}
