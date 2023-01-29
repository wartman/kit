package kit.ds;

@:using(kit.ds.Maybe.MaybeTools)
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

	public static function or<T>(maybe:Maybe<T>, def:T):T {
		return switch maybe {
			case Some(v): v;
			case None: def;
		}
	}
}
