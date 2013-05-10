
var _target = UIATarget.localTarget();

// SLTerminal's namespace, used to denote properties of the terminal
// and to avoid collisions with UIAutomation/arbitrary JS executed by/using Subliminal
var SLTerminal = {} 

SLTerminal.scriptIndex = 0;
SLTerminal.hasShutDown = false;

while(!SLTerminal.hasShutDown) {
	// Wait for a command from SLTerminal
	while (true) {
		var commandIndex = _target.frontMostApp().preferencesValueForKey("commandIndex");
		
		if (commandIndex === SLTerminal.scriptIndex) {
			break;
		}
		_target.delay(0.1);
	}
	
	// Read the command
	var command = _target.frontMostApp().preferencesValueForKey("command");
	// Uncomment to better understand what UIAutomation's doing (it may take awhile)
	//UIALogger.logMessage("command:" + SLTerminal.scriptIndex + ": " + command);
	
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
	_target.frontMostApp().setPreferencesValueForKey(SLTerminal.scriptIndex, "resultIndex");
	SLTerminal.scriptIndex++;
}
