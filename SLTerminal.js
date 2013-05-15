
var _target = UIATarget.localTarget();

var _scriptIndex = 0;
var _testingHasFinished = false;

while(!_testingHasFinished) {
	// Wait for a command from SLTerminal
	while (true) {
		var commandIndex = _target.frontMostApp().preferencesValueForKey("commandIndex");
		
		if (commandIndex === _scriptIndex) {
			break;
		}
		_target.delay(0.1);
	}
	
	// Read the command
	var command = _target.frontMostApp().preferencesValueForKey("command");
	// Uncomment to better understand what UIAutomation's doing (it may take awhile)
	//UIALogger.logMessage("command:" + _scriptIndex + ": " + command);
	
	// Evaluate the command
	var result = null;
	try {
		result = eval(command);
	} catch (e) {
		// Special case SyntaxErrors so that we can examine the malformed command
		var message = e.toString();
		if ((e instanceof Error) && e.name === "SyntaxError") {
			message += " from command: \"" + command + "\"";
		}
		_target.frontMostApp().setPreferencesValueForKey(message, "exception");
	}

	// Serialize the result only if we can guarantee that it can be serialized to the preferences
	var resultType = (typeof result);
	if (!((resultType === "string") ||
		  (resultType === "boolean") ||
		  (resultType === "number"))) {
		result = null;	
	}
	_target.frontMostApp().setPreferencesValueForKey(result, "result");

	// Notify SLTerminal that we've finished evaluation
	_target.frontMostApp().setPreferencesValueForKey(_scriptIndex, "resultIndex");
	_scriptIndex++;
}
