package kit;

class Iter {
	public static function maybeFind<I:Iterable<T>, T>(source:I, match:(value:T) -> Bool):Maybe<T> {
		var iter = source.iterator();
		while (iter.hasNext()) {
			var value = iter.next();
			if (match(value)) return Some(value);
		}
		return None;
	}

	public static function reduce<I:Iterable<T>, T, R>(source:I, handler:(accumulator:R, value:T) -> R, accumulator:R):R {
		var iter = source.iterator();
		while (iter.hasNext()) {
			accumulator = handler(accumulator, iter.next());
		}
		return accumulator;
	}

	public static function forEach<I:Iterable<T>, T>(source:I, handler:(value:T) -> Void):I {
		var iter = source.iterator();
		while (iter.hasNext()) {
			handler(iter.next());
		}
		return source;
	}

	// @todo: Potentially more, although these methods are basically the only ones I miss (and even
	// then it's mostly that I don't like how Lambda names them)
}
