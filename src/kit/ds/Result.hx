package kit.ds;

import haxe.Exception;
import kit.core.Lazy;

/**
	Represents a value that has either succeeded or failed
	(represented by a haxe.Exception).
**/
@:using(kit.ds.Result.ResultTools)
enum Result<T> {
	Success(value:T);
	Failure(exception:Exception);
}

class ResultTools {
	public static function attempt<T>(value:Lazy<T>):Result<T> {
		return try Success(value.get()) catch (e) Failure(e);
	}

	public static function unwrap<T>(result:Result<T>):T {
		return switch result {
			case Success(value): value;
			case Failure(exception): throw exception;
		}
	}

	public static function map<T, R>(result:Result<T>, transform:(value:T) -> R):Result<R> {
		return switch result {
			case Success(value): Success(transform(value));
			case Failure(exception): Failure(exception);
		}
	}

	public static function flatMap<T, R>(result:Result<T>, transform:(value:T) -> Result<R>):Result<R> {
		return switch result {
			case Success(value): transform(value);
			case Failure(exception): Failure(exception);
		}
	}

	public static function or<T>(result:Result<T>, value:Lazy<T>):T {
		return switch result {
			case Success(value): value;
			case Failure(_): value.get();
		}
	}
}
