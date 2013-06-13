<p align="center" >
  <img src="http://inkling.github.io/Subliminal/readme-images/subliminal-hero.png" alt="Subliminal" title="Subliminal">
</p>

[![Build Status](https://travis-ci.org/inkling/Subliminal.png?branch=master)](https://travis-ci.org/inkling/Subliminal)

Subliminal is an framework for writing iOS integration tests. Subliminal provides 
a familiar OCUnit/SenTest-like interface to Apple's UIAutomation framework, 
with tests written entirely in Objective-C. Subliminal also provides a powerful 
mechanism for your tests to manipulate your application directly.

Features
--------

#### Seamless Integration

Write your tests in Objective-C, and run them from Xcode. See rich-text logs 
and screenshots in Instruments. Use UIAutomation to simulate user interaction. 
Subliminal lets you use familiar tools, no dependencies required.

#### Full Control

By using UIAutomation, Subliminal can simulate almost any interaction--without 
resorting to private APIs. From navigating in-app purchase dialogs, to putting 
your app to sleep, Subliminal lets you simulate complex interaction like a user. 
And when you want to manipulate your app directly, Subliminal will help you do 
that too.

#### Scalable Tests

Define Objective-C methods to help set up and tear down tests. Leverage native 
support for continuous integration. Take confidence in Subliminal's complete 
documentation and full test coverage. Subliminal is the perfect foundation 
for your tests.

How to Get Started
------------------

* [Download Subliminal](https://github.com/inkling/Subliminal/zipball/master) 
and try out the included example app. Instructions for running the example app are [here](#running-the-example-app)
* Install Subliminal and write your first test in just 10 minutes (guide below, 
screencast [here](https://vimeo.com/67771344))
* Check out the [FAQ](#faq) or read the [complete documentation](http://inkling.github.io/Subliminal/Documentation/)
* Find support [@subliminaltest](https://twitter.com/subliminaltest) and on 
[Stack Overflow](http://stackoverflow.com/questions/tagged/subliminal)

Running the Example App
-----------------------

1. Clone the Subliminal repo: `git clone git@github.com:inkling/Subliminal.git`.
2. `cd` into the directory: `cd Subliminal`.
3. If you haven't already, setup Subliminal: `rake install`.
4. Open the Example project: `open Example/SubliminalTest.xcodeproj`.
5. Using the `Integration Tests` scheme, using an iOS 6.x Simulator, choose Product > Profile (⌘+I).
6. Under the User Templates, choose Subliminal.

Installing Subliminal
---------------------

### Downloading Subliminal

First, create a directory named "Integration Tests" in your project for 
integration tests, and download and add Subliminal to your new directory. If
you're using git for your project add Subliminal as a submodule:

```sh
mkdir Integration\ Tests
mkdir Integration\ Tests/Subliminal
git submodule add git@github.com:inkling/Subliminal.git Integration\ Tests/Subliminal/
```

Otherwise manually download and add Subliminal to `Integration Tests/Subliminal`.

### Installing Supporting Files

Now, install Subliminal's supporting files, including test file templates and 
documentation:

```sh
cd Integration\ Tests/Subliminal
rake install
```

If you'd rather read Subliminal's documentation [online](http://inkling.github.io/Subliminal/Documentation/) 
you can append `DOCS=no` to this command.

### Adding Subliminal to Your Project

Open up your project, and create a group for your integration tests. Use the 
inspector pane to make your new group represent your Integration Tests 
directory. 

![](http://inkling.github.io/Subliminal/readme-images/MakeGroupRepresentIntegrationTests.png)

Next, add Subliminal to your project by dragging its project file into your new
group.

![](http://inkling.github.io/Subliminal/readme-images/AddSubliminalToProject.png)

### Creating a Target for Your Integration Tests

Creating a separate target for your integration tests will allow you to control
exactly when your tests are run. To begin with, right click your application 
target and select "Duplicate".

![](http://inkling.github.io/Subliminal/readme-images/CreateTarget.png)

Next, rename both your new target to "Integration Tests" and the info.plist 
created for it to "Integration Tests-Info.plist". Move the reference to the 
newly created target's Info.plist file into your Integration Tests group using the 
navigator pane, and move the actual Info.plist file into your 
Integration Tests directory using the Finder. After this step you will need to
update Xcode's reference to the `plist`.

![](http://inkling.github.io/Subliminal/readme-images/UpdatePlistReference.png)

Now, link Subliminal to the Integration Tests target. To do this open the 
project inspector by selecting your project in the navigator pane. Then select 
your Integration Tests target and then the Build Phases tab, and add 
`libSubliminal.a` to the list titled "Link Binary With Libraries".

![](http://inkling.github.io/Subliminal/readme-images/LinkSubliminalBinary.png)

Also add Subliminal to the list of "Target Dependencies". This ensures Subliminal 
will be built before your application.

![](http://inkling.github.io/Subliminal/readme-images/AddSubliminalDependency.png)

Subliminal provides an `xcconfig` file to configure the rest of your target's 
settings. To apply this file to your target, expand Subliminal's project reference 
in your navigator pane, then drag the `Integration Tests.xcconfig` file into the 
base level of your Integration Tests group. Now, select your project within the 
project inspector, navigate to the "Info" tab, and base the configurations used to 
build your Integration Tests target off `Integration Tests.xcconfig`.

![](http://inkling.github.io/Subliminal/readme-images/SetConfigurations.png)

Finally, to ensure that this `xcconfig` file takes effect, you must delete two 
default build settings. Select your Integration Tests target in the project 
inspector and then select the Build Settings tab. Search for and delete the 
settings for "Product Name" and "Info.plist File": these values will be provided by 
the `Integration Tests.xcconfig` file. NOTE: To delete the "Info.plist File" setting, 
you must have renamed and moved your Integration Tests target's Info.plist file as 
described above.

![](http://inkling.github.io/Subliminal/readme-images/DeleteProductNameSetting.png)

![](http://inkling.github.io/Subliminal/readme-images/DeletePlistSetting.png)

### Creating a Scheme for Your Integration Tests Target

You're going to need to create a new scheme to run your Integration Tests 
target. Click on the name of your active scheme above the navigator pane to open
up the scheme dropdown, and select the Manage Schemes option. Depending on your 
project's settings, some extra schemes may have been created during the 
preceding steps. These schemes can be removed, but be careful not to delete the 
schemes you use regularly.

![](http://inkling.github.io/Subliminal/readme-images/DeleteExtraSchemes.png)

Now, add an additional scheme to build the Integration Tests target.

![](http://inkling.github.io/Subliminal/readme-images/CreateIntegrationTestsScheme.png)

### Running Tests on the Integration Tests Target

Finally, you'll need to add some code to you app delegate to tell Subliminal to 
begin running your tests. First build your Integration Tests scheme, so that 
Xcode can provide autocompletion results as you modify your app delegate. Then, 
import the Subliminal header at the top of your app delegate implementation file:

```objc
#if INTEGRATION_TESTING
#import <Subliminal/Subliminal.h>
#endif
```
    
and tell the shared test controller to run all test cases:

```objc
#if INTEGRATION_TESTING
[[SLTestController sharedTestController] runTests:[SLTest allTests] withCompletionBlock:nil];
#endif
```
   
Note that you do not need to direct the test controller to run specific 
tests: Subliminal automatically discovers all tests linked against the 
Integration Tests target.

Also note that this code is conditionalized by the `INTEGRATION_TESTING` preprocessor 
macro (set by `Integration Tests.xcconfig`), and so will not be built into your 
main application target. Unlike many other integration testing frameworks, Subliminal 
does not use private APIs, so it is safe to include calls to Subliminal APIs in 
any target that links against Subliminal. However, conditionalizing calls to Subliminal 
helps you keep straight exactly when you expect the tests to be run: when you 
run the Integration Tests target, not every time you launch your application.

Usage
-----

Subliminal is designed to be instantly familiar to users of OCUnit/SenTest. 
In Subliminal, subclasses of `SLTest` define tests as methods beginning with "test". 
At run-time, the `SLTestController` discovers and runs these tests. 
Here's what a sample `SLTest` implementation looks like:

```objc
@implementation STLoginTest

- (void)testLogInSucceedsWithUsernameAndPassword {
	SLTextField *usernameField = [SLTextField elementWithAccessibilityLabel:@"username field"];
	SLTextField *passwordField = [SLTextField elementWithAccessibilityLabel:@"password field" isSecure:YES];
	SLElement *submitButton = [SLElement elementWithAccessibilityLabel:@"Submit"];
	SLElement *loginSpinner = [SLElement elementWithAccessibilityLabel:@"Logging in..."];
	
    NSString *username = @"Jeff", *password = @"foo";
    [usernameField setText:username];
    [passwordField setText:password];

    [submitButton tap];

	// wait for the login spinner to disappear
    SLAssertTrueWithTimeout([_loginSpinner isInvalidOrInvisible], 
    						3.0, @"Log-in was not successful.");

    NSString *successMessage = [NSString stringWithFormat:@"Hello, %@!", username];
    SLAssertTrue([[SLElement elementWithAccessibilityLabel:successMessage] isValid], 
    			@"Log-in did not succeed.");
}

@end
```

In the body of those tests, you do some work and then make some assertions. 
In tests, you can simulate user interaction and even manipulate the application 
directly.

### Simulate User Interaction 

In Subliminal tests, you manipulate the user interface using instances of `SLElement`.
`SLElements` are proxies for the "`UIAElements`" UIAutomation uses to represent 
user interface elements: when you `-tap` an `SLElement`, that `SLElement` causes 
the appropriate bit of JavaScript to be executed to manipulate the corresponding 
`UIAElement`. Tests execute asynchronously, so they can block until UIAutomation 
is done evaluating the command.

### Manipulate the Application Directly

Subliminal lets tests access and manipulate application state by using "app hooks". 
Hooks are methods which the application registers with the test controller to 
then be invoked, by name, by the tests. Any arguments or return values of these 
methods are copied between the tests and application.

For instance, before running the tests, the application delegate could register
a "login manager" singleton as being able to programmatically log a test user in:

```objc
[[SLTestController sharedTestController] registerTarget:[LoginManager sharedManager] 
                                               forAction:@selector(logInWithInfo:)];
```
 
When tests need to log in, they could then call `loginWithInfo:`:
 
```objc
[[SLTestController sharedTestController] sendAction:@selector(logInWithInfo:)
                                         withObject:@{
                                                        @"username": @"john@foo.com",
                                                        @"password": @"Hello1234"
                                                     }];
```

App hooks help developers write independent tests: only one test need evaluate 
the login UI, while the others can use the programmatic interface. App hooks 
also let test writers re-use their application's code without making their tests 
dependent on the application's structure, and without sharing state between the 
application and tests.

Requirements
------------

Subliminal has been tested with the latest Xcode (4.6.2), and currently requires 
iOS 6.x. iOS 5 support is literally [in review](https://github.com/inkling/Subliminal/pull/11), 
and iOS 7 support will be coming soon!

Continuous Integration
----------------------

You can run Subliminal tests from the command line using the `subliminal-test` 
script, which takes care of building your application and running the tests on the 
appropriate simulator or device.

To use `subliminal-test`, first:

1. 	[Install Subliminal](#installing-subliminal) on the test machine
2. 	"Share" the "Integration Tests" scheme to make it available to the CI server: 
	in Xcode, click "Product" -> "Schemes" -> "Manage Schemes…", click the "Shared" 
	checkbox next to the scheme, and check the resulting file into source control.
3. 	Enable GUI scripting: Open System Preferences and check "Enable Access for 
	Assistive Devices in the Accessibility" preference pane.

A minimal test runner would then look something like this: 

```sh
#!/bin/bash

# Run the tests in the non-retina iPhone Simulator
DEVICE="iPhone"

# A bug in Instruments (http://openradar.appspot.com/radar?id=1544403) 
# requires that the script be invoked with the current user's login password in order 
# to run fully un-attended
PASSWORD="password1234"

OUTPUT_DIR=reports
mkdir -p "$OUTPUT_DIR"

# Returns 0 on success, 1 on failure
# Log output and screenshots will be placed in $OUTPUT_DIR
"$PROJECT_DIR/Integration Tests/Subliminal/Supporting Files/CI/subliminal-test" \
	-project "$YOUR_PROJECT" \
	-sim_device "$DEVICE" \
	-login_password "$PASSWORD" \
	-output "$OUTPUT_DIR"
```

For CI servers like [Jenkins](http://jenkins-ci.org/), you can process test logs 
into JUnit reports using the `subliminal_uialog_to_junit` script:

```sh
"$PROJECT_DIR/Integration Tests/Subliminal/Supporting Files/CI/subliminal_uialog_to_junit" \
	-i "$OUTPUT_DIR/Run\ Data/Automation\ Results.plist" \
	-o "$OUTPUT_DIR/junit.xml"
```

Subliminal runs integration tests against itself using [Travis](https://travis-ci.org/). 
Take a look at its [configuration file](https://github.com/inkling/Subliminal/blob/master/.travis.yml) 
for an example.

FAQ
---

### Subliminal and Other Integration Test Frameworks

* 	How is Subliminal different from other integration test frameworks?

	Most other integration test frameworks fall into two categories: entirely 
	Objective-C based, or entirely UIAutomation-based.

	Frameworks that are entirely Objective-C based, like [KIF](https://github.com/square/KIF/), 
	[Frank](https://github.com/moredip/Frank), etc., must hack the application's 
	touch-handling system, using private APIs, to simulate user interaction. 
	There is thus no guarantee that they accurately simulate a user's input. 
	Moreover, these frameworks can only simulate interaction with the application, 
	as opposed to interaction with the device, other processes like in-app purchase 
	alerts, etc.

	Frameworks that are entirely based on Apple's UIAutomation framework require 
	cumbersome workflows--writing tests in JavaScript, in Instruments--which do not 
	make use of the developer's existing toolchain. Moreover, they offer the developer 
	no means of manipulating the application directly--it is a complete black box 
	to a UIAutomation-based test.

	Only Subliminal combines the convenience of writing tests in Objective-C 
	with the power of UIAutomation.

* 	How is Subliminal different than UIAutomation?

	Besides the limitations of UIAutomation described above, it is extremely 
	difficult to write UIAutomation tests. This is because UIAutomation requires 
	that user interface elements be identified by their position within the 
	["element hierarchy"](https://developer.apple.com/library/ios/#documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/UsingtheAutomationInstrument/UsingtheAutomationInstrument.html#//apple_ref/doc/uid/TP40004652-CH20-SW88), like

	```js
	UIATarget.localTarget().frontMostApp().mainWindow().tableViews()[0].cells()[0].
	```

	These references are not only difficult to read but are also difficult to write.
	To refer to any particular element, you have to describe its entire ancestry, 
	while including only the views that UIAutomation deems necessary (images, yes; 
	accessible elements, maybe; private `UIWebView` subviews, sure!).

	UIAutomation-based tests are not meant to be written, but to be "recorded" 
	using Instruments. This forces dependence on Instruments, and makes the tests 
	difficult to modify thereafter.

	Subliminal allows developers to identify elements by their properties, 
	independent of their position in the element hierarchy. Subliminal then 
	generates the full reference for the developer. Subliminal abstracts away 
	the complexity of UIAutomation scripts to let developers focus on writing tests.

### Writing and Running Tests

* 	How do I write a test?

	Very much like you would write a unit test using OCUnit/SenTest: make a new 
	subclass of `SLTest`, and define some "test cases" (methods whose names begin 
	with "test", which take no arguments, and which return void). In those test cases, 
	simulate user interaction or manipulate the application directly, then make 
	assertions.

	The "Integration test class" file template (in the Xcode "New File" dialog, 
	under "iOS" -> "Subliminal" in the sidebar) stubs out some useful methods. 
	
*	How do I run my application's tests?
	1. 	Switch to your project's "Integration Tests" scheme, whichever device or 
		iOS 6.x Simulator you like.
	2. 	Select "Profile" from the "Product" menu (`Cmd-I`).
	3. 	Choose the "Subliminal" trace template (under "User" -> "All" in the sidebar 
		of the dialog that pops up) .
	
	To re-run the tests when they finish, press "Stop" and then "Record" in 
	Instruments' upper left-hand corner. If you make changes to the tests, 
	you must "push" the changes to Instruments by selecting "Product" -> "Profile" 
	again.

*	How do I run specific tests?

	By default, Subliminal will run all the test cases (methods whose names begin 
	with "test", which take no arguments, and return `void`) of all the `SLTest` 
	subclasses. You can restrict testing to particular test cases by prefixing 
	their names with "focus\_". You can "focus" all test cases of a particular 
	`SLTest` subclass by prefixing its name with "focus_", too. Don't forget to 
	remove the prefixes before committing your changes!
	
### Debugging Tests

*	How can I disable UIAutomation's debug logs?

	UIAutomation's debug logs record every user interaction simulated by the 
	Automation instrument. They can be quite noisy. To prevent the logs from 
	appearing in Instruments' GUI, execute this command in Terminal:

	```sh
	defaults write com.apple.dt.Instruments UIAVerboseLogging 4096
	```

	To re-enable the logs, execute:
	
	```sh
	defaults delete com.apple.dt.Instruments UIAVerboseLogging
	```

	The `subliminal-test` script prevents these logs from appearing when tests 
	are run at the command line, unless the `--verbose_logging` flag is specified.

*	How can Subliminal tell me where I'm getting "invalid element" and/or 
	"element not tappable" exceptions?

	Use the `UIAElement` macro to log the filename and line number of calls to 
	`-[SLUIAElement tap]`, etc.:

	```objc
	SLButton *button = [SLButton buttonWithAccessibilityLabel:@"foo"];
	[UIAElement(button) tap];	// vs. [button tap];
	```

*	How can I debug tests while running?

	You can easily attach the debugger to Instruments, to stop at breakpoints set 
	in Xcode, using the following process:
	1.	Change the build configuration used to profile the "Integration Tests" 
		scheme from "Release" (the default) to "Debug" (in Xcode, click "Product" 
		-> "Schemes" -> "Manage Schemes…", double-click the "Integration Tests" 
		scheme, select the "Profile" build phase, and then change the build 
		configuration). Otherwise, debug information will be optimized away during 
		build.

		You need not worry that building in "Debug" will cause your tests to not 
		reflect the actual "Release" state of the app--scripts like `subliminal-test` 
		can override the configuration to use "Release" when building the app 
		from the command line.
	2.	Launch the tests, then click "Product" -> "Attach to Process" -> (name 
		of the test process, likely "Integration Tests").

		This may be done at any time while the tests are running. If you need 
		to break immediately after launch, you may find it useful to give yourself 
		time to attach the debugger by setting `-[SLTestController shouldWaitToStartTesting]` 
		to `YES`.

Contributing
------------

We are very much looking forward to working with 3rd-party developers to make Subliminal 
even better, and will post contributing guidelines very soon.

Credits
-------

Created by [Jeff Wear](https://github.com/wearhere), made possible by [Inkling](https://www.inkling.com/), 
with help from:

* [William Green](http://ca.linkedin.com/pub/william-green/21/724/105)
* [John Detloff](https://github.com/jmdetloff)
* [Aaron Golden](http://stackoverflow.com/users/2172667/aaron-golden)
* [Lukhnos Liu](https://github.com/lukhnos)
* [Aaron Haney](https://github.com/ahaneyinkling)

and Subliminal's [growing list of contributors](https://github.com/inkling/Subliminal/contributors).

Contact
-------

Follow Subliminal ([@subliminaltest](https://twitter.com/subliminaltest)) and 
Jeff Wear ([@wear_here](https://twitter.com/wear_here/)) on Twitter.

Copyright and License
---------------------

Copyright 2013 Inkling Systems, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
