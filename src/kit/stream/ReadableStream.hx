package kit.stream;

import kit.event.Event;
import haxe.Exception;

interface ReadableStream<T> {
	public final onData:Event<T>;
	public final onEnd:Event<T>;
	public final onError:Event<Exception>;
	public final onClose:Event<Void>;

	public function isReadable():Bool;
	public function pause():Void;
	public function resume():Void;
	public function pipe(dest:WritableStream<T>):WritableStream<T>;
	public function close():Void;
}
