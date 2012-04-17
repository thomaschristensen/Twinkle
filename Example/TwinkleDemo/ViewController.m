//
//  ViewController.m
//  TwinkleDemo
//
//  Created by Thomas Christensen on 18/04/12.
//  Copyright 2012 Nordija A/S
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ViewController.h"
#import "Twinkle.h"

#define APP_PLIST_URL @"http://dl.dropbox.com/u/10001969/IOS/twinkle/TwinkleDemo.plist"

@implementation ViewController
@synthesize productVersionLabel;
@synthesize buildNumberLabel;
@synthesize statusLabel;
@synthesize nextBuildNumberLabel;
@synthesize nextProductVersionLabel;

- (void)viewDidUnload {
    [self setProductVersionLabel:nil];
    [self setBuildNumberLabel:nil];
    [self setStatusLabel:nil];
    [self setNextBuildNumberLabel:nil];
    [self setNextProductVersionLabel:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkVersion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

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

@end