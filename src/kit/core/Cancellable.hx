package kit.core;

interface CancellableObject {
	public function isCanceled():Bool;
	public function cancel():Void;
}

// @todo: Decide if this and Disposable should be merged.

@:forward
abstract Cancellable(CancellableObject) from CancellableObject {
	@:from public static function ofArray(items:Array<Cancellable>):Cancellable {
		return new CancellableList(items);
	}
}

class CancellableList implements CancellableObject {
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
