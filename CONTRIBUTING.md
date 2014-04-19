## Filing Issues

### Bug Reports

If you think you've found a bug, do your best to allow others to replicate it:

* Succinctly describe the bug.
* Include version information for iOS, OS X, Xcode and Subliminal.
* Include relevant context—were you running from the command line? From a hosted CI environment?
* Provide steps to replicate the issue.
* Provide a small sample project replicating the issue. This will isolate the cause and make replication easier. Consider forking Subliminal and writing a new, failing unit or integration test (see below for details).
* Try to find where the bug is within Subliminal itself.


Not all this will be necessary—just do your best to let other programmers understand and replicate your bug.

## Contributing

### Pull Requests

Subliminal welcomes pull requests! To contribute, fork the Subliminal repo, clone your fork, then make your changes. If you're adding functionality or fixing a bug, you must add new tests covering the changes. Only refactoring and documentation changes require no new tests.

* If you can test your changes without `UIAutomation` attached
(most changes to `SLTestController` and `SLTest` fall into this category), 
add `SenTest` unit tests to the "Subliminal Unit Tests" group.

* If you need `UIAutomation` to test your changes (e.g. if you added a subclass of `SLElement`), add integration tests to the "Subliminal Integration Tests -> Tests" group. 
See [`SLIntegrationTest.h`](https://github.com/inkling/Subliminal/blob/master/Integration%20Tests/SLIntegrationTest.h) for further instructions.

    > Protip: You can use the "Subliminal integration test class" file template to stub out integration tests and their associated view controllers.

#### Running Tests Locally 

* To run the unit tests:
	1. Switch to the "Subliminal Unit Tests" scheme.
	2. Select "Test" from the "Product" menu (⌘+U).
	    * Use the ⬦ icons in Xcode's line number gutter to run the individual tests you've added.
* To run the integration tests:
    1. Switch to the "Subliminal Integration Tests" scheme.
    2. Select "Profile" from the "Product" menu (⌘+I) and choose the Subliminal template.
        * Prefix class or test names with `focus_` to test only your changes (make sure not to commit focused tests).
        
When you open a pull request, Travis CI will automatically test your changes against all supported SDKs and devices, so you don't need to run every test locally. All tests must pass on Travis for your pull request to be accepted.

### Documentation

Anyone can edit [Subliminal's documentation](https://github.com/inkling/Subliminal/wiki), which is kept on a Github Wiki. Github Wikis don't support pull requests, so if you're unsure of your edit you can open an issue to discuss your change.
