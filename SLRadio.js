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
			_target.frontMostApp().setPreferencesValueForKey(response, _outputDefaultsKey);
		}
	}
	_inputButton().tap();
}
