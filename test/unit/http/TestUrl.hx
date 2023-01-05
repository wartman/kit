package unit.http;

import kit.http.Url;

using Medic;

class TestUrl implements TestCase {
	public function new() {}

	@:test('Parses a full url as expected')
	function testFromString() {
		var url = new Url('https://www.foo.com/bar?foo=bin#foo');
		url.scheme.equals('https');
		url.domain.equals('www.foo.com');
		url.path.equals('/bar');
		url.fragment.equals('foo');
		url.query.get('foo').equals('bin');
	}

	@:test('Parses a partial url')
	function testPartials() {
		var url = new Url('foo.com/');
		url.scheme.equals(null);
		url.domain.equals('foo.com');
		url.path.equals('');

		var url = new Url('/bar?foo=bin');
		url.scheme.equals(null);
		url.domain.equals(null);
		url.path.equals('/bar');
		url.query.get('foo').equals('bin');
	}

	@:test('Stringifies as expected')
	function testToString() {
		var url = new Url('https://www.foo.com/bar?foo=bin#foo');
		url.toString().equals('https://www.foo.com/bar?foo=bin#foo');
		url.withScheme('http').toString().equals('http://www.foo.com/bar?foo=bin#foo');
		url.withDomain('www.bar.net').toString().equals('https://www.bar.net/bar?foo=bin#foo');
		url.withQueryParam('bar', 'bin').toString().equals('https://www.foo.com/bar?foo=bin&bar=bin#foo');
	}
}
