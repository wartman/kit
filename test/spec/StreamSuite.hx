package spec;

class StreamSuite extends Suite {
	function execute() {
		describe('kit.Stream', () -> {
			describe('Using a simple string stream', () -> {
				var stream = Stream.value('hello').append(Stream.value('world'));

				it('can be appended and collected', spec -> {
					spec.expect(1);

					stream
						.append(Stream.value('and stuff'))
						.collect()
						.inspect(values -> values.join(' ').should().be('hello world and stuff'));
				});

				it('can be mapped', spec -> {
					spec.expect(1);

					stream
						.map(value -> value.toUpperCase())
						.collect()
						.inspect(values -> values.join(' ').should().be('HELLO WORLD'));
				});

				it('can be iterated over using the each method', spec -> {
					spec.expect(1);

					var buf = new StringBuf();
					stream
						.each(item -> buf.add(item))
						.inspect(_ -> buf.toString().should().be('helloworld'));
				});
			});
		});
	}
}
