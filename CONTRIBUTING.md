## Yay pull requests!

### And tests!

Only refactoring and documentation changes require no new tests. 
If you are adding functionality or fixing a bug, we need tests!
	
* If you can test your changes without `UIAutomation` attached
(most changes to `SLTestController` and `SLTest` fall into this category), 
add `SenTest` unit tests to the "Subliminal Unit Tests" group.

* If you need `UIAutomation` to test your changes (i.e. if you modified `SLElement`), 
add integration tests to the "Subliminal Integration Tests -> Tests" group. 
See `SLIntegrationTests.h` for further instructions.

	* Protip: install the "Subliminal integration test class" file template 
	to make writing Subliminal integration tests easier. To do so, 
	run [`InstallFileTemplates.sh`](https://git.inkling.com/ios/Subliminal/blob/master/Documentation/File%20Templates/InstallFileTemplates.sh) 
	with the `-d` flag. It will install on top of any pre-existing templates.

Now, run the tests (even if you didn't write a new test).
All tests must pass for your pull request to be accepted!

* Run the unit tests:
	1. Switch to the "Subliminal Unit Tests" scheme, latest iPhone simulator.
	2. Select "Test" from the "Product" menu (`Cmd-U`).

* Run the integration tests [like any other Subliminal tests](https://git.inkling.com/ios/Subliminal#faq-aka-stuff-which-should-eventually-go-somewhere-above), using the 
latest iPhone simulator.