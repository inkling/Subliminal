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

#### Setting up Subliminal for Development

Subliminal welcomes pull requests! To get started, fork the Subliminal repo, clone your fork, then make your changes on a branch. GitHub has [a guide](https://help.github.com/articles/fork-a-repo) to this process if you'd like more information.

Then, from the root directory of your fork, execute `rake install DEV=yes && git submodule update --init --recursive` to fully initialize Subliminal as well as install some file templates to help you write tests.

> You should run the above command even if you had already installed Subliminal. Subliminal will "re-install" without problem.

#### Making Changes

If you're adding functionality or fixing a bug, you must add new tests covering the changes (Only refactoring and documentation changes require no new tests). What kind of tests you should write depend on your specific changes:

* If you can test your changes without `UIAutomation` attached
(most changes to `SLTestController` and `SLTest` fall into this category), 
add `SenTest` unit tests to the "Subliminal Unit Tests" group.

* If you need `UIAutomation` to test your changes (e.g. if you added a subclass of `SLElement`), add integration tests to the "Subliminal Integration Tests -> Tests" group. 
See [`SLIntegrationTest.h`](https://github.com/inkling/Subliminal/blob/master/Integration%20Tests/SLIntegrationTest.h) for further instructions.

    > Protip: Use the "Subliminal integration test class" file template to stub out integration tests and their associated view controllers.

#### Running Your Tests

* To run the unit tests:
	1. Switch to the "Subliminal Unit Tests" scheme.
	2. Select "Test" from the "Product" menu (⌘+U).
	    * Use the ⬦ icons in Xcode's line number gutter to run the individual tests you've added.
* To run the integration tests:
    1. Switch to the "Subliminal Integration Tests" scheme.
    2. Select "Profile" from the "Product" menu (⌘+I) and choose the Subliminal template.
        * Prefix class or test names with `focus_` to test only your changes (make sure not to commit focused tests).
        
When you open a pull request, Travis CI will automatically test your changes against all supported SDKs and devices, so you don't need to run every test locally. All tests must pass on Travis for your pull request to be accepted.

#### Documenting New API

If your changes add new public API, add [documentation comments](http://nshipster.com/documentation/) like so:

```objc
/**
 The name of the current test case.

 @return If an `SLTestCaseViewController` is currently presented, its test case's
 name, otherwise `nil`.
 */
- (NSString *)currentTestCase;
```

These comments are used to generate the documentation you see when you option-click a method in Xcode and for Subliminal's [online API docs](http://inkling.github.io/Subliminal/Documentation/). Use the existing documentation comments as a template for how to structure your own.

##### Building the Documentation

If you'd like to build Subliminal's documentation locally, run these steps to install Appledoc 2.1:

> Note that this is not the latest version of Appledoc (see [here](https://github.com/inkling/Subliminal/issues/71)), and will overwrite whatever you might currently have installed. You can just let Travis test that the documentation builds correctly if you prefer.

```bash
curl --progress-bar --output /tmp/appledoc-2.1.mountain_lion.bottle.tar.gz http://inkling.github.io/Subliminal/Documentation/appledoc-2.1.mountain_lion.bottle.tar.gz
tar -C /tmp -zxf /tmp/appledoc-2.1.mountain_lion.bottle.tar.gz
# This assumes that /usr/local/bin is in your PATH
cp /tmp/appledoc/2.1/bin/appledoc /usr/local/bin
cp -Rf /tmp/appledoc/2.1/Templates/ ~/.appledoc
```

Then choose the "Subliminal Documentation" scheme in Xcode to build the docs. If any documentation is incomplete, errors will be generated showing you where. The documentation must successfully build on Travis for your pull request to be accepted.

### Subliminal's Wiki

Anyone can edit [Subliminal's non-API documentation](https://github.com/inkling/Subliminal/wiki), which is kept on a Github Wiki. Github Wikis don't support pull requests, so if you're unsure of your edit you can open an issue to discuss your change.
