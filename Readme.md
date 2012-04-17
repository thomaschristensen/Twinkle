Twinkle

A small library to handle self updating of IOS Enterprise applications. 
The libray compares the current application's version information with the
new version's plist and pop's up a notification to the viewer, potentially 
leading to the upgrade itself.

The library builds upon the priciple of treating CFBundleShortVersionString as product version and
CFBundleVersion as build number. Product versions are in the form of "x.y.z" and build numbers are integers.
If this principle is not followed then the library will fail.

Background
Enterprise Distributed applications are placed on a web server and installed directly from there, outside of the Apple
 appstore. This approach hinders the user to be automatically notified when there are new versions of the app available.
 By using the library, that can be automated.