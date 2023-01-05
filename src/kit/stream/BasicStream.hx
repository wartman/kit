package kit.stream;

import haxe.Exception;
import kit.event.Event;

using kit.stream.StreamTools;

/**
	A DuplexStream that simply passes data through a callback,
	optionally transforming it. Can be used as the basis for creating
	simple, manually controlled streams.
**/
class BasicStream<T, R> implements DuplexStream<T, R> {
	/**
		Create a BasicStream that does not transform the data it receives.
	**/
	public static function through<T>():BasicStream<T, T> {
		return new BasicStream(v -> v);
	}

	public final onPipe:Event<ReadableStream<R>> = new Event<ReadableStream<R>>();
	public final onData:Event<T> = new Event<T>();
	public final onEnd:Event<T> = new Event<T>();
	public final onError:Event<Exception> = new Event<Exception>();
	public final onDrain:Event<Void> = new Event();
	public final onClose:Event<Void> = new Event();

	final transform:(value:R) -> T;

	var isPaused:Bool = false;
	var isDraining:Bool = false;
	var isClosed:Bool = false;
	var isStreamReadable:Bool = true;
	var isStreamWritable:Bool = true;

	public function new(transform) {
		this.transform = transform;
	}

	public function isReadable():Bool {
		return isStreamReadable;
	}

	public function isWritable():Bool {
		return isStreamWritable;
	}

	public function pause() {
		isPaused = true;
	}

	public function resume() {
		if (isDraining) {
			isDraining = false;
			onDrain.dispatch();
		}
		isPaused = false;
	}

	public function write(data:R):Bool {
		if (!isStreamWritable) {
			return false;
		}

		onData.dispatch(transform(data));
		if (isPaused) {
			isDraining = true;
			return false;
		}

		return true;
	}

	public function end(?data:R):Void {
		if (!isStreamWritable) {
			return;
		}

		if (data != null) {
			write(data);
			if (!isStreamWritable) {
				return;
			}
		}

		isStreamReadable = false;
		isStreamWritable = false;
		isPaused = true;
		isDraining = false;

		onEnd.dispatch(null);
		close();
	}

	public function pipe(dest:WritableStream<T>):WritableStream<T> {
		return StreamTools.pipe(this, dest);
	}

	public function close() {
		if (isClosed) {
			return;
		}

		isClosed = true;
		isStreamReadable = false;
		isStreamWritable = false;
		isPaused = true;
		isDraining = false;

		onClose.dispatch();

		this.cancelDuplexEvents();
	}
}
