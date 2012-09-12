_testingHasFinished = false;


var _target = UIATarget.localTarget();

function wait(f, timeout, retryDelay) {
	if (!timeout) var timeout = 5.0;
	if (!retryDelay) var retryDelay = 0.25;

	var startTime = Math.round(Date.now() / 1000);
	var fTrue = false;
	while (!(fTrue = f()) &&
			((Math.round(Date.now() / 1000) - startTime) < timeout)) {
		_target.delay(retryDelay);
	}
	
	return fTrue;
}

var _outputDefaultsPath = null;
function registerOutputDefaultsPath() {
	if (!_outputDefaultsPath) {
		// '~' doesn't expand in the call to find, so we look up the user's home directory first
		var homeDirectoryResult = _target.host().performTaskWithPathArgumentsTimeout("/bin/sh", ["-c", "echo ~"], 5);
		var homeDirectory = homeDirectoryResult.stdout;
		// strip newline character at end of result (for some reason)
		homeDirectory = homeDirectory.substring(0, homeDirectory.length - 1);
		var searchPath = homeDirectory + "/Library/Application\ Support/iPhone\ Simulator/" + _target.systemVersion() + "/Applications";
		var preferencesFilename = _target.frontMostApp().bundleID() + ".plist";
		var findOutputDefaultsPathResult = _target.host().performTaskWithPathArgumentsTimeout("/usr/bin/find", [searchPath, "-name", preferencesFilename], 5);
		_outputDefaultsPath = findOutputDefaultsPathResult.stdout;
		if ((typeof(_outputDefaultsPath) != "string") || _outputDefaultsPath.length == 0) {
			UIALogger.logIssue("Could not locate application preferences.");
			_testingHasFinished = true;
		}
	}
}

var _outputDefaultsKey = "SLTerminal_input";

var _inputButton = function() {
	return _target.frontMostApp().mainWindow().buttons()["SLTerminal_outputButton"];
}

UIATarget.onAlert = function(alert) {
	// tests will handle alerts
	return true;
}

while(!_testingHasFinished) {
	if(!wait(function(){ return _inputButton().isVisible(); }, 5.0)) {
		UIALogger.logMessage("Target application appears to have died. Aborting testing.");
		_testingHasFinished = true; continue;
	};
	
	var command = _inputButton().label();
	var response = null;
	try {
		// Uncomment to better understand what UIAutomation's doing (it may take awhile) 
		// UIALogger.logMessage("command: " + command);
		response = eval(command);
	} catch (e) {
		// format exceptions for parsing by the SLTerminal
		response = "SLTerminalExceptionOccurred: " + e.toString();
		// special case SyntaxErrors so that we can examine the malformed command
		if ((e instanceof Error) && e.name == "SyntaxError") {
			response += " from expression: \"" + command + "\"";
		}
	} finally {
		if (typeof(response) == "string" && response.length > 0) {
			_target.host().performTaskWithPathArgumentsTimeout("/usr/bin/defaults", ["write", _outputDefaultsPath, _outputDefaultsKey, "'" + response + "'"], 5);
		}
	}
	_inputButton().tap();
}
