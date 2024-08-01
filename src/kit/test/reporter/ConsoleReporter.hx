package kit.test.reporter;

import kit.test.Outcome;

using StringTools;

typedef ConsoleDisplayOptions = {
	public final ?title:String;
	public final trackProgress:Bool;
	public final verbose:Bool;
}

class ConsoleReporter implements Reporter {
	final options:ConsoleDisplayOptions;
	var started:Bool = false;

	public function new(?options) {
		this.options = options != null ? options : {
			trackProgress: true,
			verbose: false
		};
	}

	public function progress(assertion:Assertion) {
		if (!started) {
			started = true;
			if (options.title != null) print('\n' + options.title + '\n');
		}
		if (!options.trackProgress) return;
		switch assertion {
			case Pass: print('.');
			case Fail(_, _): print('F');
			case Warn(_): print('W');
		}
	}

	public function report(outcome:Outcome) {
		var buf = new StringBuf();
		var total = 0;
		var passing = 0;
		var failures = 0;

		buf.add('\n');

		function reportSuite(suite:SuiteOutcome, indent:Int) {
			var status = suite.status();
			var passed = status.passed;
			var failed = status.failed;

			passing += passed;
			failures += failed;
			total += passed + failed;

			if (options.verbose) {
				buf.add('\n');
				buf.add(''.lpad(' ', indent));
				buf.add(suite.description);
				buf.add('\n');

				for (test in suite.tests) {
					var passed = test.status().failed == 0;
					var display = passed ? '✓' : 'X';

					buf.add(''.lpad(' ', indent + 4));
					buf.add('...${test.description} $display');

					if (!passed) {
						buf.add('\n');
						var pad = ''.lpad(' ', indent + 6);
						for (assertion in test.assertions) switch assertion {
							case Pass:
							case Fail(reason, pos):
								buf.add(pad);
								buf.add('(failed) ${pos.fileName}:${pos.lineNumber} - ${reason}');
								buf.add('\n');
							case Warn(message):
								buf.add(pad);
								buf.add('(warning) ${message}');
								buf.add('\n');
						}
					}
					buf.add('\n');
				}
			}

			// for (child in suite.children) reportSuite(child, indent + 4);
		}

		for (suite in outcome.suites) reportSuite(suite, 0);

		buf.add('\n');
		buf.add('Status: ${failures == 0 ? 'OK' : 'FAILED'}');
		buf.add('\n');
		buf.add('${total} tests | ${passing} passed | ${failures} failed');
		buf.add('\n');

		print(buf.toString());
	}
}

// @todo: Make this better
function print(v:Dynamic) {
	#if js
	js.Syntax.code('
      var msg = {0};
      var safe = {1};
      var d;
      if (
        typeof document != "undefined"
        && (d = document.getElementById("medic-trace")) != null
      ) {
        d.innerHTML += safe; 
      } else if (
        typeof process != "undefined"
        && process.stdout != null
        && process.stdout.write != null
      ) {
        process.stdout.write(msg);
      } else if (typeof console != "undefined") {
        console.log(msg);
      }
    ', Std.string(v), StringTools.htmlEscape(v)
		.split('/n')
		.join('</br>'));
	#else
	Sys.print(Std.string(v));
	#end
}
