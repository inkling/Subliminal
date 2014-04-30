## Installation/Updating

To install Subliminal see the [installation walkthrough](https://github.com/inkling/Subliminal/wiki#installing-subliminal)
on the wiki.

To update Subliminal:
* If you installed Subliminal **manually**, download Subliminal [from the Releases page](https://github.com/inkling/Subliminal/releases)
and drop in the new sources.
* If you installed Subliminal **using Git submodules**, execute `git checkout <tag>` from
Subliminal's root directory and commit your change in your project.
* If you installed Subliminal **using Cocoapods**,  update your Podfile (optional) and then
execute `pod update Subliminal` from your project directory.

Then, to update your installation of Subliminal's docs (if desired), execute `rake install` from
Subliminal's root directory (if you installed Subliminal manually or using Git submodules) or
from `YOUR_PROJECT_DIR/Pods/Subliminal` (if you installed Subliminal using Cocoapods).

_Please also see the notes below for release-specific update instructions._

## Master

## 1.1

[Complete diff](https://github.com/inkling/Subliminal/compare/1.0.1...1.1)

_Because of the significant period of time between the 1.0.1 and 1.1 releases, the 1.1 changelog is heavily abridged._

##### Updated Requirements

* Subliminal now requires Xcode 5.1. iOS 5.1 is still supported, though this is the last release
to support iOS 5.1. To test in the iOS 5.1 Simulator, users must run OS X 10.8 and manually
add the iOS 5.1 Simulator to Xcode as described [here](http://stackoverflow.com/a/22494536/495611).
* Subliminal no longer requires the user's password to run from the command-line. Users
should stop passing the `-login_password` and `--live` options to the `subliminal-test` script
and instead [pre-authorize their computers to run Instruments](https://github.com/inkling/Subliminal/wiki/Continuous-Integration#faq).

##### Notable Features

* Subliminal no longer requires the user's password to run from the command line.  
  [Jeffrey Wear](https://github.com/wearhere) [#181](https://github.com/inkling/Subliminal/pull/181)

* Use Instrument's new `-w` flag to run on a specific device  
  [Jeffrey Wear](https://github.com/wearhere) [#181](https://github.com/inkling/Subliminal/pull/181)

* Cocoapods support  
  [Max Tagher](https://github.com/MaxGabriel) [#30](https://github.com/inkling/Subliminal/pull/30)
    
* Pretty-printed test output  
  [Jeffrey Wear](https://github.com/wearhere) [#134](https://github.com/inkling/Subliminal/pull/134)
    
* Randomized test order  
  [Jeffrey Wear](https://github.com/wearhere) [#80](https://github.com/inkling/Subliminal/pull/80)

* Support testing on a device without the app having already been installed  
  [Jeffrey Wear](https://github.com/wearhere) [#75](https://github.com/inkling/Subliminal/pull/75)

* Support retina devices  
  [Nikita Zhuk](https://github.com/nzhuk) [#45](https://github.com/inkling/Subliminal/pull/45)

###### New SLElement subclasses

* SLSwitch  
  [Justin Mutter](https://github.com/j-mutter) [#85](https://github.com/inkling/Subliminal/pull/85)

* SLStatusBar  
  [Leon Jiang](https://github.com/leoninkling) [#55](https://github.com/inkling/Subliminal/pull/55)

* SLWebTextView  
  [Jeffrey Wear](https://github.com/wearhere) [#49](https://github.com/inkling/Subliminal/pull/49)

* SLTextView  
  [Jeffrey Wear](https://github.com/wearhere) [#49](https://github.com/inkling/Subliminal/pull/49)
    
###### Other API additions 

* Screenshot any SLElement  
  [Jordan Zucker](https://github.com/jzucker2) [#129](https://github.com/inkling/Subliminal/pull/129)

* Capture screenshots  
  [Jeffrey Wear](https://github.com/wearhere) [#118](https://github.com/inkling/Subliminal/pull/118)

* Double tap elements  
  [Jeffrey Wear](https://github.com/wearhere) [#121](https://github.com/inkling/Subliminal/pull/121)
    
* Custom Keyboard Support  
  [Justin Mutter](https://github.com/j-mutter) [#105](https://github.com/inkling/Subliminal/pull/105)
    
* Type characters that require tapping and holding  
  [Aaron Golden](https://github.com/aegolden) [#95](https://github.com/inkling/Subliminal/pull/95)
    
* Tap an element's activation point  
  [Jeffrey Wear](https://github.com/wearhere) [#61](https://github.com/inkling/Subliminal/pull/61)
    
* Check if an element has keyboard focus  
  [Jeffrey Wear](https://github.com/wearhere) [#49](https://github.com/inkling/Subliminal/pull/49)
    
* Touch and hold `SLElement`s  
  [Aaron Golden](https://github.com/aegolden) [#44](https://github.com/inkling/Subliminal/pull/44)
  


##### Notable bug fixes

* Workaround `isVisible` not working in non-portrait orientations  
  [Jeffrey Wear](https://github.com/wearhere) [#180](https://github.com/inkling/Subliminal/pull/180)

* Fix interacting with collection view cell contents by including mock views in the accessibility path  
  [Jeffrey Wear](https://github.com/wearhere) [#179](https://github.com/inkling/Subliminal/pull/179)

* Detect the simulator launching in an inconsistent state (Travis CI Stability improvement)  
  [Jeffrey Wear](https://github.com/wearhere) [#148](https://github.com/inkling/Subliminal/pull/148)
    
* Guard against `nil` in `accessibilityElementAtIndex:`  
  [Chad Etzel](https://github.com/jazzychad) [#125](https://github.com/inkling/Subliminal/pull/125)

* Search for the deepest element within the element hierarchy (iOS 7 fix)  
  [Nanouk](https://github.com/j2bbayle) [#116](https://github.com/inkling/Subliminal/pull/116)

