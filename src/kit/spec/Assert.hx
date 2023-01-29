package kit.spec;

import kit.ds.Maybe;

final class Assert {
	static var currentSpec:Maybe<Spec> = None;

	public static function bind(spec:Spec) {
		switch currentSpec {
			case Some(_):
				// @todo: We can provide better info here
				throw 'Attempted to bind Assert while it was already bound';
			case None:
				currentSpec = Some(spec);
		}
	}

	public static function clear() {
		currentSpec = None;
	}

	public static function should<T>(subject:T) {
		return switch currentSpec {
			case Some(spec): new Should(subject, spec);
			default: throw 'Cannot use Assert outside of a spec';
		}
	}
}
