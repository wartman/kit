package kit.stream;

import haxe.Exception;
import kit.event.Event;

using kit.stream.StreamTools;

final class CompositeStream<T> implements DuplexStream<T, T> {
	public final onPipe:Event<ReadableStream<T>> = new Event<ReadableStream<T>>();
	public final onData:Event<T> = new Event<T>();
	public final onEnd:Event<T> = new Event<T>();
	public final onError:Event<Exception> = new Event<Exception>();
	public final onDrain:Event<Void> = new Event();
	public final onClose:Event<Void> = new Event();

	final readable:ReadableStream<T>;
	final writable:WritableStream<T>;

	var subscriptions:Array<EventSubscription<Dynamic>> = [];
	var isClosed:Bool = false;

	public function new(readable, writable) {
		this.readable = readable;
		this.writable = writable;

		if (!this.readable.isReadable() || !this.writable.isWritable()) {
			close();
			return;
		}

		forwardEvents();
	}

	function forwardEvents() {
		subscriptions = [
			readable.onData.add(onData.dispatch),
			readable.onEnd.add(onEnd.dispatch),
			readable.onError.add(onError.dispatch),
			readable.onClose.add(close),

			writable.onDrain.add(onDrain.dispatch),
			writable.onPipe.add(onPipe.dispatch),
			writable.onError.add(onError.dispatch),
			writable.onClose.add(close)
		];
	}

	public function isReadable():Bool {
		return readable.isReadable();
	}

	public function isWritable():Bool {
		return writable.isWritable();
	}

	public function pause() {
		readable.pause();
	}

	public function write(data:T):Bool {
		return writable.write(data);
	}

	public function resume() {
		if (!writable.isWritable()) {
			return;
		}
		readable.resume();
	}

	public function end(?data:T) {
		readable.pause();
		writable.end(data);
	}

	public function pipe(dest:WritableStream<T>):WritableStream<T> {
		return StreamTools.pipe(this, dest);
	}

	public function close() {
		if (isClosed) {
			return;
		}

		isClosed = true;

		readable.close();
		writable.close();

		onClose.dispatch();

		clearEventSubscriptions();

		this.cancelDuplexEvents();
	}

	function clearEventSubscriptions() {
		for (subscription in subscriptions) {
			subscription.cancel();
		}
	}
}
