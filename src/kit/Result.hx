package kit;

/**
	A simple enum (and associated tools) to handle values that
	may be invalid.
**/
@:using(kit.Result.ResultTools)
enum Result<T, E = Error> {
	Ok(value:T);
	Error(error:E);
}

class ResultTools {
	/**
		Returns the value of the Result if `Ok` or `null` if there's an
		error.

		Use `orThrow()` (without an argument for `message`) if you want
		an error to be thrown if the `Result` is not `Ok`.
	**/
	public static function unwrap<T, E>(result:Result<T, E>):Null<T> {
		return switch result {
			case Ok(value): value;
			case Error(_): null;
		}
	}

	/**
		Transform the value of the Result.

		If the `Result` is an `Error(...)` the transform method will be skipped
		and the `Error` will be returned instead. This allows you easily
		manipulate Result values without having to check if they're `Ok` or
		`Error` first.
	**/
	public static function map<T, E, R>(result:Result<T, E>, transform:(value:T) -> R):Result<R, E> {
		return switch result {
			case Ok(value): Ok(transform(value));
			case Error(error): Error(error);
		}
	}

	/**
		Similar to `map(...)` with the distinction that the transform function
		returns a Result as well. If the Result is Ok it will be replaced
		by the new result; if it is Error the current Error will be persisted.
	**/
	public static function flatMap<T, E, R>(result:Result<T, E>, transform:(value:T) -> Result<R, E>):Result<R, E> {
		return switch result {
			case Ok(value): transform(value);
			case Error(error): Error(error);
		}
	}

	/**
		Similar to `map`, but works on the Error branch instead.
	**/
	public static function mapError<T, E, R>(result:Result<T, E>, transform:(e:E) -> R):Result<T, R> {
		return switch result {
			case Ok(value): Ok(value);
			case Error(error): Error(transform(error));
		}
	}

	/**
		Convert an array of Results into a single Result with an array of values.
	**/
	public static function collect<T, E>(results:Array<Result<T, E>>):Result<Array<T>, E> {
		var out:Array<T> = [];
		for (result in results) switch result {
			case Ok(value): out.push(value);
			case Error(error): return Error(error);
		}
		return Ok(out);
	}

	/**
		Return the value of the Result if it's Ok or return the given fallback. 
	**/
	public static function or<T, E>(result:Result<T, E>, fallback:Lazy<T>):T {
		return switch result {
			case Ok(value): value;
			case Error(_): fallback.get();
		}
	}

	/**
		Return the value of the Result if it's Ok or throw the error if it's Error.

		You can also provide an optional `userError` to throw in place of the
		value of Error.
	**/
	public static function orThrow<T, E, F>(result:Result<T, E>, ?userError:Lazy<F>):T {
		return switch result {
			case Ok(value): value;
			case Error(_) if (userError != null): throw userError.get();
			case Error(error): throw error;
		}
	}

	@:deprecated
	public static function toMaybe<T, E>(result:Result<T, E>):Maybe<T> {
		return switch result {
			case Ok(value): Some(value);
			case Error(_): None;
		}
	}
}
