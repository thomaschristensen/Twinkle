## Twinkle

Twinkle is a small library to handle self updating of IOS Enterprise applications. The libray compares the current application's version information with the
new version's plist and pop's up a notification to the viewer, potentially leading to the upgrade itself. Usable for IOS Enterprise Applications.

## How To Get Started
The library is fairly straight forward to use. After installing the library (see below) perform the following:
1. Implement TwinkleDelegate in your AppDelegate or initial view controller.
2. Instantiate a Twinkle instance with the URL of the Enterprise Distributed App's plist file.
3. Extract current app's product version and build number.
4. Call detectNewVersion on the Twinkle instance.
A thread in the background will handle the network request will call the TwinkleDelegate method newVersionDetected if an update is available. See code below.

``` objective-c
#define APP_PLIST_URL @"http://www.mydomain.com/twinkle/TwinkleDemo.plist"

- (IBAction)checkVersion:(id)sender {
    self.productVersionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.buildNumberLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    Twinkle *twinkle = [[Twinkle alloc] initWithAppPlistURL:[[NSURL alloc] initWithString:APP_PLIST_URL]];
    [twinkle detectNewVersion:self.productVersionLabel.text currentBuild:self.buildNumberLabel.text delegate:self];
    self.nextProductVersionLabel.text = twinkle.serverProductVersion;
    self.nextBuildNumberLabel.text = twinkle.serverBuildNumber;
    self.statusLabel.text = twinkle.lastStatusMessage;
}

- (void)newVersionDetected:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New version available" message:message delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Update", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1) {
        NSString *strUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", APP_PLIST_URL];
        NSURL *url = [NSURL URLWithString:strUrl];
        [[UIApplication sharedApplication] openURL:url];
    }
} 
```

Notice that the download and install process automatically starts if the plist url is opened by the shared application!

## Version Information Format
The library builds upon the principle of treating CFBundleShortVersionString as product version and CFBundleVersion as build number. However, in the Enterprise Distribution wrapping the plist only contains CFBundleShortVersionString which is renamed to "build-version". Product versions are in the form of "x.y.z" and build numbers are integers. A "bundle-build-number" can be added manually but the library does not expect it. If this principle is not followed then the library will fail.

## Install
Either copy the three files (Twinkle.h, Twinkle.m and TwinkleDelegate.h) into your own project by dragging and dropping them in xcode, or drag and drop the included Twinkle xcode project by itself. This will cause the project to be a subproject and you will need to make your project depend on it as well as including the library in the linking phase.

## Background
Enterprise Distributed applications are placed on a web server and installed directly from there, outside of the Apple AppStore. This approach hinders the user to be automatically notified when there are new versions of the app available. By using the library, that can be automated.

## Demo
The library consists of only a few calls. See the included simple demo application for more information. In order to see that working make an Enterprise Distribution plist like to following and place it on the specified url, referred to as APP_PLIST_URL in the demo code.

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<string>software-package</string>
					<key>url</key>
					<string>http://www.mydomain.com/twinkle/TwinkleDemo.ipa</string>
				</dict>
				<dict>
					<key>kind</key>
					<string>full-size-image</string>
					<key>needs-shine</key>
					<false/>
					<key>url</key>
					<string>http://www.mydomain.com/twinkle/TwinkleDemo_large.png</string>
				</dict>
				<dict>
					<key>kind</key>
					<string>display-image</string>
					<key>needs-shine</key>
					<false/>
					<key>url</key>
					<string>http://www.mydomain.com/twinkle/TwinkleDemo_small.png</string>
				</dict>
			</array>
			<key>metadata</key>
			<dict>
				<key>bundle-identifier</key>
				<string>com.mydomain.TwinkleDemo</string>
				<key>bundle-version</key>
				<string>1.0.1</string>
				<key>kind</key>
				<string>software</string>
				<key>subtitle</key>
				<string>Demo by Thomas</string>
				<key>title</key>
				<string>TwinkleDemo</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>
```