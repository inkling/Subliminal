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

	On the `shared/subliminal` branch of `ios/inkling-ipad`, I've set up an "Integration Tests" target.
	
	1. Switch to this target, and hit "Profile".
	2. Select the UIAutomation instrument.
	3. Stop recording.
	4. Import the "SLRadio.js" script found in the "Integration Tests" directory.
	5. Go back to Xcode and hit "Profile" again.
	
	Tests will now run. To re-run the tests when they finish, hit the record button (to stop Instruments, which keeps going even after the script stops), then switch back to Xcode and hit "Profile" again.
	
3. How do I run specific tests?

	By default, Subliminal will run all the methods of all the `SLTest` subclasses which begin with "test". You can restrict testing to particular `SLTest` subclasses by passing an array with just those tests to the `SLTestController` in `-application:didFinishLaunchingWithOptions:`:
	
		NSArray *testsToRun = @[[SLTest testNamed:@"OneTest"], [SLTest testNamed:@"TwoTest"]];
		[testController runTests:testsToRun];
	
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
Subliminal