package kit.stream;

inline function pipe<T>(source:ReadableStream<T>, target:WritableStream<T>, ?options:{forwardEnd:Bool}):WritableStream<T> {
	// Source not readable. Do nothing.
	if (!source.isReadable()) {
		return target;
	}

	// Target not writable. Pause the source and do nothing.
	if (!target.isWritable()) {
		source.pause();
		return target;
	}

	// Dispatch the `onPipe` signal.
	target.onPipe.dispatch(source);

	// Forward all source 'onData' signals to `target.write(...)`.
	var dataLink = source.onData.add(data -> {
		if (!target.write(data)) {
			source.pause();
		}
	});
	target.onClose.add(() -> {
		dataLink.cancel();
		source.pause();
	});

	// Forward all target `onDrain` signals to resume the source.
	var drainLink = target.onDrain.add(() -> source.resume());
	source.onClose.add(() -> drainLink.cancel());

	// Forward the source `onEnd` signal to the target if requested
	// (if no options are provided, defaults to `true`).
	var shouldForwardEnd = options != null ? options.forwardEnd : true;
	if (shouldForwardEnd) {
		var endLink = source.onEnd.add(data -> target.end(data));
		target.onClose.add(() -> endLink.cancel());
	}

	return target;
}

inline function map<T, R>(readable:ReadableStream<T>, transform:(value:T) -> R):ReadableStream<R> {
	var through = new BasicStream(transform);
	readable.pipe(through);
	return through;
}

inline function cancelDuplexEvents<T, R>(duplex:DuplexStream<T, R>) {
	duplex.onData.cancel();
	duplex.onEnd.cancel();
	duplex.onPipe.cancel();
	duplex.onDrain.cancel();
	duplex.onClose.cancel();
	duplex.onError.cancel();
}

inline function cancelReadableEvents<T>(readable:ReadableStream<T>) {
	readable.onData.cancel();
	readable.onEnd.cancel();
	readable.onClose.cancel();
	readable.onError.cancel();
}

inline function cancelWritableEvents<T>(writable:WritableStream<T>) {
	writable.onPipe.cancel();
	writable.onDrain.cancel();
	writable.onClose.cancel();
	writable.onError.cancel();
}
