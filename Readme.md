## Twinkle

Twinkle is a small library to handle self updating of IOS Enterprise applications. The libray compares the current application's version information with the
new version's plist and pop's up a notification to the viewer, potentially leading to the upgrade itself. Usable for IOS Enterprise Applications.

## How To Get Started

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

## Version Information Format
The library builds upon the priciple of treating CFBundleShortVersionString as product version and CFBundleVersion as build number. Product versions are in the form of "x.y.z" and build numbers are integers. If this principle is not followed then the library will fail.

## Background
Enterprise Distributed applications are placed on a web server and installed directly from there, outside of the Apple appstore. This approach hinders the user to be automatically notified when there are new versions of the app available. By using the library, that can be automated.

## Demo
The library consists of only a few calls. See the included simple demo application for more information.