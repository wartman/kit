package kit.core;

interface CancellableLink {
	public function isCanceled():Bool;
	public function cancel():Void;
}

@:forward
abstract Cancellable(CancellableLink) from CancellableLink {
	@:from public static function ofArray(items:Array<Cancellable>):Cancellable {
		return new CancellableList(items);
	}

	@:from public static function ofFunction(link:() -> Void):Cancellable {
		return new SimpleCancelableLink(link);
	}
}

class SimpleCancelableLink implements CancellableLink {
	var callback:() -> Void;

	public function new(callback) {
		this.callback = callback;
	}

	public function isCanceled():Bool {
		return callback != null;
	}

	public function cancel() {
		if (callback != null) {
			callback();
			callback = null;
		}
	}
}

class CancellableList implements CancellableLink {
	var items:Null<Array<Cancellable>>;

	public function new(items:Array<Cancellable>) {
		this.items = items;
	}

	public function isCanceled():Bool {
		return items == null;
	}

	public function cancel() {
		if (items == null) return;
		var pending = items;
		items = null;
		for (item in pending) if (!item.isCanceled()) {
			item.cancel();
		}
	}
}
