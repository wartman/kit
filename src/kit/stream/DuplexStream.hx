package kit.stream;

interface DuplexStream<T, R> extends ReadableStream<T> extends WritableStream<R> {}
