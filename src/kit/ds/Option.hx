package kit.ds;

/**
	An Option is a wrapper type which can either have a value (Some) or not a
	value (None). 

	Note: this is a copy of Haxe's builtin Option enum, done so that 
	  we could add the @:using to it.
**/
@:using(kit.ds.Option.OptionTools)
enum Option<T> {
	Some(value:T);
	None;
}

class OptionTools {
	public static function unwrap<T>(option:Option<T>):Null<T> {
		return switch option {
			case Some(v): v;
			case None: null;
		}
	}

	public static function map<T, R>(option:Option<T>, transform:(value:T) -> Option<R>):Option<R> {
		return switch option {
			case Some(v): transform(v);
			case None: None;
		}
	}

	public static function flatMap<T, R>(option:Option<T>, transform:(value:Option<T>) -> Option<R>):Option<R> {
		return transform(option);
	}

	public static function or<T>(option:Option<T>, def:T):T {
		return switch option {
			case Some(v): v;
			case None: def;
		}
	}
}
