package kit;

using kit.Testing;

class StreamSuite extends Suite {
	final stream = Stream.value('hello').append(Stream.value('world'));

	@:test(expects = 1)
	function canBeAppendedAndCollected() {
		return stream
			.append(Stream.value('and stuff'))
			.collect()
			.inspect(values -> values.join(' ').equals('hello world and stuff'));
	}

	@:test(expects = 1)
	function canBeMapped() {
		return stream
			.map(value -> value.toUpperCase())
			.collect()
			.inspect(values -> values.join(' ').equals('HELLO WORLD'));
	}

	@:test(expects = 1)
	function canBeIteratedOverUsingTheEachMethod() {
		var buf = new StringBuf();
		return stream
			.each(item -> buf.add(item))
			.inspect(_ -> buf.toString().equals('helloworld'));
	}
}
