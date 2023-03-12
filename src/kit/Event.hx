package kit;

import haxe.Constraints.Function;
import kit.Cancellable;

// Implementation (including the genericBuild macro) from: https://gist.github.com/nadako/b086569b9fffb759a1b5

@:genericBuild(kit.internal.EventBuilder.build())
class Event<Rest> {}

abstract class EventBase<T:Function> implements CancellableLink {
	var head:EventSubscription<T>;
	var tail:EventSubscription<T>;
	var toAddHead:EventSubscription<T>;
	var toAddTail:EventSubscription<T>;
	var dispatching:Bool;
	var canceled:Bool = false;

	public function new() {
		dispatching = false;
	}

	public function add(listener:T, once:Bool = false):EventSubscription<T> {
		if (canceled) {
			throw 'Cannot add a listener to a canceled signal';
		}

		var sub = new EventSubscription(this, listener, once);

		if (dispatching) {
			if (toAddHead == null) {
				toAddHead = toAddTail = sub;
			} else {
				toAddHead.next = sub;
				sub.previous = toAddTail;
				toAddTail = sub;
			}
		} else {
			if (head == null) {
				head = tail = sub;
			} else {
				tail.next = sub;
				sub.previous = tail;
				tail = sub;
			}
		}

		return sub;
	}

	public inline function addOnce(listener:T) {
		return add(listener, true);
	}

	public function isCanceled() {
		return canceled;
	}

	public function cancel() {
		canceled = true;

		var sub = head;

		while (sub != null) {
			sub.signal = null;
			sub = sub.next;
		}

		head = null;
		tail = null;
		toAddHead = null;
		toAddTail = null;
	}

	public function remove(sub:EventSubscription<T>) {
		if (head == sub)
			head = head.next;
		if (tail == sub)
			tail = tail.previous;
		if (toAddHead == sub)
			toAddHead = toAddHead.next;
		if (toAddTail == sub)
			toAddTail = toAddTail.previous;
		if (sub.previous != null)
			sub.previous.next = sub.next;
		if (sub.next != null)
			sub.next.previous = sub.previous;
		sub.signal = null;
	}

	inline function startDispatch() {
		dispatching = true;
	}

	inline function endDispatch() {
		dispatching = false;
		if (toAddHead != null) {
			if (head == null) {
				head = toAddHead;
				tail = toAddTail;
			} else {
				tail.next = toAddHead;
				toAddHead.previous = tail;
				tail = toAddTail;
			}
			toAddHead = toAddTail = null;
		}
	}
}

@:allow(kit.EventBase)
class EventSubscription<T:Function> implements CancellableLink {
	final listener:T;
	final once:Bool;

	var signal:EventBase<T>;
	var previous:EventSubscription<T>;
	var next:EventSubscription<T>;

	function new(signal, listener, once) {
		this.signal = signal;
		this.listener = listener;
		this.once = once;
	}

	public function isCanceled() {
		return signal == null;
	}

	public function cancel():Void {
		if (signal != null) {
			signal.remove(this);
			signal = null;
		}
	}
}
