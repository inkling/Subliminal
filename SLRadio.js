
var _target = UIATarget.localTarget();

UIATarget.onAlert = function(alert) {
	// tests will handle alerts
	return true;
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
