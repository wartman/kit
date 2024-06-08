package kit.http;

import haxe.Exception;

using StringTools;

@:forward
abstract Url(UrlObject) from UrlObject {
	@:from public inline static function ofString(url:String):Url {
		return UrlObject.parse(url);
	}

	public function new(url:String) {
		this = UrlObject.parse(url);
	}

	@:to public function toString():String {
		return this.toString();
	}
}

// @todo: We're missing host and port (if we're being inspired by PSR-7),
// but this is OK for now.
class UrlObject {
	// @todo: urlDecode?
	public static function parse(url:String):UrlObject {
		url = url.trim();

		var scheme = switch url.indexOf('://') {
			case -1: null;
			case index:
				var part = url.substring(0, index);
				url = url.substr(index + '://'.length);
				part;
		}

		var domain = switch url.indexOf('/') {
			case -1:
				switch url.indexOf('?') {
					case -1:
						url;
					case index:
						url.substring(0, index);
				}
			case index:
				url.substring(0, index);
		}

		if (domain.length == 0)
			domain = null;
		else {
			url = url.substr(domain.length);
		}

		var path = '';

		if (!url.startsWith('?')) switch url.lastIndexOf('?') {
			case -1:
				switch url.indexOf('#') {
					case -1:
						path = url;
						url = '';
					case index:
						path = url.substring(0, index);
						url = url.substring(index);
				}
			case index:
				path = url.substring(0, index);
				url = url.substring(index);
		}

		var fragment = switch url.indexOf('#') {
			case -1: null;
			case index:
				var part = url.substring(index + 1);
				url = url.substring(0, index);
				part;
		}

		var query = switch url.indexOf('?') {
			case -1:
				new UrlQuery([]);
			case index:
				var part = url.substr(index + 1);
				url = '';
				UrlQuery.parse(part);
		}

		return new UrlObject(scheme, domain, path, fragment, query);
	}

	public final scheme:Null<String>;
	public final domain:Null<String>;
	public final path:String;
	public final query:UrlQuery;
	public final fragment:Null<String>;

	public function new(scheme, domain, path, fragment, query) {
		this.scheme = scheme;
		this.domain = domain;
		this.path = path;
		this.fragment = fragment;
		this.query = query;
	}

	public function withScheme(newScheme):Url {
		return new UrlObject(newScheme, domain, path, fragment, query);
	}

	public function withDomain(newDomain):Url {
		return new UrlObject(scheme, newDomain, path, fragment, query);
	}

	public function withPath(newPath):Url {
		return new UrlObject(scheme, domain, newPath, fragment, query);
	}

	public function withFragment(newFragment):Url {
		return new UrlObject(scheme, domain, path, newFragment, query);
	}

	public function withoutQuery():Url {
		return new UrlObject(scheme, domain, path, fragment, new UrlQuery([]));
	}

	public function withQueryParam(key, value):Url {
		return new UrlObject(scheme, domain, path, fragment, query.with(key, value));
	}

	public function withoutQueryParam(key):Url {
		return new UrlObject(scheme, domain, path, fragment, query.without(key));
	}

	public function toString():String {
		var buffer = new StringBuf();
		if (scheme != null) {
			buffer.add(scheme);
			buffer.add('://');
		}

		if (domain != null) {
			buffer.add(domain);
		}

		if (path.length > 0) {
			if (!path.startsWith('/')) buffer.add('/');
			buffer.add(path);
		}

		var q = query.toString();
		if (q.length > 0) {
			buffer.add('?');
			buffer.add(q);
		}

		if (fragment != null) {
			buffer.add('#');
			buffer.add(fragment);
		}

		return buffer.toString();
	}
}

@:forward(get, exists, iterator, keyValueIterator)
abstract UrlQuery(Map<String, String>) {
	@:from public static function parse(query:String):UrlQuery {
		var params:Map<String, String> = [];
		var parts = query.split('&');

		for (param in parts) switch param.split('=') {
			case [key, value]: params.set(key.trim(), value.trim().urlDecode());
			default: throw new Exception('Malformed url');
		}

		return new UrlQuery(params);
	}

	public function new(params) {
		this = params;
	}

	public function with(key, value) {
		var params = this.copy();
		params.set(key, value);
		return new UrlQuery(params);
	}

	public function without(key) {
		var params = this.copy();
		params.remove(key);
		return new UrlQuery(params);
	}

	public function toString() {
		return [for (key => value in this) '$key=${value.urlEncode()}'].join('&');
	}
}
