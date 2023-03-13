package kit;

@:using(kit.Maybe.MaybeTools)
enum Maybe<T> {
	Some(value:T);
	None;
}

class MaybeTools {
	public static function unwrap<T>(maybe:Maybe<T>):Null<T> {
		return switch maybe {
			case Some(v): v;
			case None: null;
		}
	}

	public static function map<T, R>(maybe:Maybe<T>, transform:(value:T) -> Maybe<R>):Maybe<R> {
		return switch maybe {
			case Some(v): transform(v);
			case None: None;
		}
	}

	public static function flatMap<T, R>(maybe:Maybe<T>, transform:(value:Maybe<T>) -> Maybe<R>):Maybe<R> {
		return transform(maybe);
	}

	public static function or<T>(maybe:Maybe<T>, value:Lazy<T>):T {
		return switch maybe {
			case Some(value): value;
			case None: value.get();
		}
	}

	public static function orThrow<T>(maybe:Maybe<T>, ?message:String):T {
		return switch maybe {
			case Some(value): value;
			case None: throw message == null ? 'No value exists' : message;
		}
	}
}
