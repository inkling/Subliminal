Subliminal
==========

Subliminal is an iOS integration test framework. Subliminal provides a familiar `OCUnit/SenTest`-like interface to `UIAutomation`, with tests written entirely in Objective-C. It's thus powerful while being easy to use, understand, and maintain.

Full documentation will be forthcoming, here and in the code, but for now, here's an overview of how Subliminal is structured.

**TL;DR** skip ahead to the FAQ.

Installation
-----

To be written. For now, I've done this already, on the `shared/subliminal` branch of `ios/inkling-ipad`.

Usage
-----

Subliminal is designed to be instantly familiar to users of `OCUnit/SenTest`. In Subliminal, subclasses of `SLTest` define tests as methods beginning with "test". At run-time, the `SLTestController` discovers and runs these tests. Here's what a sample `SLTest` implementation looks like:

	@implementation STLoginTest

	- (void)testLogIn {
		SLTextField *usernameField = [SLTextField elementWithAccessibilityLabel:@"username field"];
		SLTextField *passwordField = [SLTextField elementWithAccessibilityLabel:@"password field" isSecure:YES];
		SLElement *submitButton = [SLElement elementWithAccessibilityLabel:@"Submit"];
		SLElement *loginSpinner = [SLElement elementWithAccessibilityLabel:@"Logging in..."];
		
	    NSString *username = @"Jeff", *password = @"foo";
	    [UIAElement(usernameField) setText:username];
	    [UIAElement(passwordField) setText:password];
    
	    [UIAElement(submitButton) tap];
    
	    [UIAElement(loginSpinner) waitUntilInvisible:3.0];
    
	    NSString *successMessage = [NSString stringWithFormat:@"Hello, %@!", username];
	    SLAssertTrue([UIAElement([SLElement elementWithAccessibilityLabel:successMessage]) isValid], @"Log-in did not succeed.");
	}

	@end


In the body of those tests, you do some work and then make some assertions. Because the tests live inside your application, that work can involve talking to application code. Otherwise, your tests will manipulate the user interface. 

In Subliminal tests, you talk to `UIAutomation`, and manipulate the user interface, using instances of `SLElement`. `SLElements` are proxies for the "UIAElements" `UIAutomation` uses to represent user interface elements: when you `-tap` an `SLElement`, that `SLElement` causes the appropriate bit of Javascript to be executed to manipulate the corresponding `UIAElement`. Tests execute asynchronously, so they'll block until `UIAutomation`'s done evaluating the command.

Subliminal emits log statements much like `SenTest`, at the start/end of each test suite (`SLTest` subclass), and throughout the individual tests. It does this using an instance of the `SLLogger`. These instances serve as adapters to your particular testing enviroment, by allowing you to define the (Javascript) logging function used to record test messages, and customize the language used to describe each event. Subliminal currently provides an adapter for UIAutomation, allowing you to view the results of your tests as run using Instruments.

FAQ (aka stuff which should eventually go somewhere above)
----------------------------------------------------------

1. How do I write a test?

	Very much like you would write a unit test using `OCUnit/SenTest`: make a new subclass of `SLTest`, and define some methods on it beginning with "test". Do some work, make some assertions. Note, calls to `UIAutomation` (through `SLElement`) will throw exceptions as appropriate, if their corresponding `UIAElements` are invalid or whatever. All exceptions are caught by the framework and logged.
	
2. How do I run the tests?
	
	1. Switch to the "Integration Tests" scheme.
	2. Select "Profile" from the "Product" menu (`Cmd-I`).
	3. Choose the `Automation` instrument.
	4. Wait for the simulator to launch, then stop recording (the button in the top 
	left of Instruments, or `Cmd-R`).
	5. Add the [`SLRadio.js`](https://git.inkling.com/ios/Subliminal/blob/master/SLRadio.js) script using the drop-down menu in the middle of `Instruments`' left sidebar.
	6. Press the record button again.
	
	To re-run the tests when they finish, hit the record button twice (once to stop 
	"recording" the tests, then again to restart.) If you make changes to the code, 
	you must hit "Profile" from within Xcode before re-running the tests.
	
3. How do I run specific tests?

	By default, Subliminal will run all the test cases (methods beginning with "test") 
	of all the `SLTest` subclasses. You can restrict testing to particular test 
	cases by prefixing their names with "focus_". You can "focus" all test cases 
	of a particular `SLTest` subclass by prefixing its name with "focus_", too. 
	Don't forget to remove the prefixes before committing your changes!
	
4. What's up with the `UIAElement` macro?

	Think of it as that you're preparing to send a message to the `UIAElement` corresponding to the wrapped `SLElement`.
	
	Really, it's a way to log the filename/line number of a `UIAutomation` call, for debugging purposes.
	
5. There's no method on `SLElement` to do < something that `UIElement` does >. How might I implement it?
	
	Consider making a subclass of `SLElement` which defines the necessary functionality. See `SLAlert` and `SLTextField` for examples.
	
6. How will this work with continous integration?

	We'll implement a subclass of `SLLogger` which provides an interface to our CI test-runner of choice, i.e. all logging calls will be transmitted to Jasmine instead of to `UIAutomation`. That's my current thought, anyway.
	
7. Should I transmit raw Javascript over the wire?

	That's a bold move seeing as how `UIAutomation`/Javascript offer nothing in the way of a compiler or debugger -- are you feeling lucky?
	
	Use/make reliable abstractions, like `SLElement` and `SLLogger`, wherever possible.
	
8. Can I see this all working somewhere?

	Sure. Check out the `SubliminalTest` project in "Documentation/Examples". That example links in [`OCMock`](https://github.com/inkling/ocmock) to show off some _really_ slick stuff we can do around test setup.
	
9. How can I disable UIAutomation logs?

	UIAutomation debug logs record every action taken (button.tap(), etc.) and show up in Instruments' trace log. These can sometimes be useful but are mostly noise. Disable them using this command:
	 
	`defaults write com.apple.dt.Instruments UIAVerboseLogging -int 4096`
	
	to reset:
	
	`defaults delete com.apple.dt.Instruments UIAVerboseLogging`

	You will need to restart Instruments after either change to see an effect. (Reproduced from [this Stack Overflow answer](http://stackoverflow.com/a/8760768)).
	
10. How can I debug the test while it's running?

	If the test is stuck or you want to step throught some code, you can attach `Xcode.app` or `lldb`
	
	1. `Xcode.app`: The unreliable GUI

		It's possible to use `Xcode.app` to debug the tests. You can do it at anytime with Project -> Attach to Process -> By Process Identifier (PID) or Name..., then attach to "Integration Test". This method is buggy and may stop working after a couple of times because either `launchd` or `Instruments` or `Xcode.app` is confused. You may have to reboot just to get it to work again.

	2. `lldb`: The reliable CLI

		Using `lldb` on the command line is more reliable although not as easy to use. You'll have to set breakpoints yourself, etc. Here's how to interact with the tests:

		```sh
		# Attach to an existing test
		process attach -n "Integration Test"
		# OR
		# Attach to the next test
		process attach --waitfor --continue -n "Integration Test"
		
		
		# Find the stuck thread
		process interrupt
		thread list
		thread backtrace <thread number>
		```
		
