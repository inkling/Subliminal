
var _target = UIATarget.localTarget();

// We return true to let the tests handle alerts 
// rather than have UIAutomation automatically dismiss them.
// The variable is defined outside the function 
// so that it can be manipulated by the test controller.
var _testsHandleAlerts = true;
UIATarget.onAlert = function(alert) {
	return _testsHandleAlerts;
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
