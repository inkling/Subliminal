
var _target = UIATarget.localTarget();

// SLTerminal's namespace, used to denote properties of the terminal
// and to avoid collisions with UIAutomation/arbitrary JS executed by/using Subliminal
var SLTerminal = {} 

// private variable
SLTerminal._scriptIndex = 0;

// public variables (manipulated by SLTerminal)
SLTerminal.hasShutDown = false;

while(!SLTerminal.hasShutDown) {
	// Wait for JavaScript from SLTerminal
	while (true) {
		var scriptIndex = _target.frontMostApp().preferencesValueForKey("scriptIndex");
		
		if (scriptIndex === SLTerminal._scriptIndex) {
			break;
		}
		_target.delay(0.1);
	}
	
	// Read the JavaScript
	var script = _target.frontMostApp().preferencesValueForKey("script");
	// Uncomment to better understand what UIAutomation's doing (it may take awhile)
	//UIALogger.logMessage("script:" + SLTerminal._scriptIndex + ": " + script);
	
	// Evaluate the script
	var result = null;
	try {
		result = eval(script);
	} catch (e) {
		// Special case SyntaxErrors so that we can examine the malformed script
		var message = e.toString();
		if ((e instanceof Error) && e.name === "SyntaxError") {
			message += " from script: \"" + script + "\"";
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
	_target.frontMostApp().setPreferencesValueForKey(SLTerminal._scriptIndex, "resultIndex");
	SLTerminal._scriptIndex++;
}
