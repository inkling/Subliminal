
var _target = UIATarget.localTarget();

// The below function will return true for an alert 
// iff the tests should handle and dismiss that alert.
// SLTestController manipulates the function via the variables below
// (see -automaticallyDismissAlerts and -pushHandlerForAlert:).
var _testsHandleAlerts = false;
var _alertHandlers = [];
UIATarget.onAlert = function(alert) {
	// if the tests will handle all alerts return true immediately
	if (_testsHandleAlerts) return true;

	// otherwise enumerate registered handlers, last first
	for (var handlerIndex = _alertHandlers.length - 1; handlerIndex >= 0; handlerIndex--) {
		var handler = _alertHandlers[handlerIndex];
		// if a handler matches the alert, remove it and return true
		if (handler(alert) === true) {
			_alertHandlers.splice(handlerIndex, 1);
			return true;
		}
	};

	// the tests won't handle this alert, so UIAutomation should dismiss it
	return false;
}


var _scriptIndex = 0;
var _testingHasFinished = false;

while(!_testingHasFinished) {
	while (true) {
		var commandIndex = _target.frontMostApp().preferencesValueForKey("commandIndex");
		
		if (commandIndex == _scriptIndex) {
			break;
		}
		_target.delay(0.1);
	}
	
	var command = _target.frontMostApp().preferencesValueForKey("command");
	// Uncomment to better understand what UIAutomation's doing (it may take awhile)
	//UIALogger.logMessage("command:" + _scriptIndex + ": " + command);
	
	var result = null;
	try {
		result = eval(command);
	} catch (e) {
		// Special case SyntaxErrors so that we can examine the malformed command
		var message = e.toString();
		if ((e instanceof Error) && e.name == "SyntaxError") {
			message += " from command: \"" + command + "\"";
		}
		_target.frontMostApp().setPreferencesValueForKey(message, "exception");
	} finally {
		_target.frontMostApp().setPreferencesValueForKey(result, "result");
		_target.frontMostApp().setPreferencesValueForKey(_scriptIndex, "resultIndex");
	}
	_scriptIndex++;
}
