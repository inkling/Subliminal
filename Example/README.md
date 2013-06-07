To run the example project's tests:

1. From the directory where you've downloaded Subliminal (the directory above 
the `Example` directory), execute: `rake install DOCS=no`.
2. Open `SubliminalTest.xcodeproj`.
3. Switch to the "Integration Tests" scheme (you may need to click "Autocreate Schemes Now") 
and the latest iPhone Simulator.
4. Select "Profile" from Xcode's "Product" menu.
5. In the sidebar of the dialog that pops up, select "User" -> "All", then select 
the "Subliminal" trace template.

To re-run the tests, press "Stop" and then "Record" in Instruments' upper left-hand 
corner. If you make changes to the tests (`STSimpleTest` and `STLoginTest`), 
you must "push" the changes to Instruments by selecting `Product -> Profile` 
again.
