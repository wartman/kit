package kit;

import haxe.Exception;
import kit.Lazy;

@:using(kit.Result.ResultTools)
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

	public static function mapException<T, E:Exception>(result:Result<T>, transform:(e:Exception)->E):Result<T> {
		return switch result {
			case Success(value): Success(value);
			case Failure(exception): Failure(transform(exception));
		}
	}

	public static function or<T>(result:Result<T>, value:Lazy<T>):T {
		return switch result {
			case Success(value): value;
			case Failure(_): value.get();
		}
	}

	public static function orThrow<T>(result:Result<T>, ?message:String):T {
		return message == null ? unwrap(result) : switch result {
			case Success(value): value;
			case Failure(_): throw message;
		};
	}
}
