package kit.stream;

import kit.event.Event;
import haxe.Exception;

interface WritableStream<T> {
	public final onPipe:Event<ReadableStream<T>>;
	public final onError:Event<Exception>;
	public final onDrain:Event<Void>;
	public final onClose:Event<Void>;

	public function isWritable():Bool;
	public function write(data:T):Bool;
	public function end(?data:T):Void;
	public function close():Void;
}
