//
//  Twinkle.m
//  Twinkle
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


#import "Twinkle.h"
#import "TwinkleDelegate.h"

@implementation Twinkle 

@synthesize appPlistURL = _appPlistURL;
@synthesize serverProductVersion = _serverProductVersion;
@synthesize serverBuildNumber = _serverBuildNumber;
@synthesize lastStatusMessage = _lastStatusMessage;

- (id)initWithAppPlistURL:(NSURL *)appPlistURL {
    self = [super init];
    if (self) {
        _appPlistURL = appPlistURL;
    }

    return self;
}

/**
* Converts the input product version string to an array of numbers.
* A version string of 1.3.2 becomes three NSNumber elements in a NSArray,
* respecting the sequence left from right.
*/
- (NSArray *)convertToMajorMinor:(NSString *)currentVersion {
    NSArray *chunks = [currentVersion componentsSeparatedByString:@"."];
    NSMutableArray *majorMinor = [NSMutableArray arrayWithCapacity:[chunks count]];
    for (NSString *stringNumber in chunks) {
        [majorMinor addObject:[NSNumber numberWithInteger:[stringNumber integerValue]]];
    }
    return majorMinor;
}

/**
* Generates a log-ready version string from the array of version numbers and the build number.
* Format is y.x.z - b
*/
- (NSString *)generateVersionString:(NSArray *)currentMajorMinor buildNumber:(NSNumber *)buildNumber {
    NSMutableString *out = [NSMutableString string];
    bool first = true;
    for (NSNumber *num in currentMajorMinor) {
        if (!first)
            [out appendString:@"."];
        [out appendString:num.stringValue];
        first = false;
    }
    [out appendString:@" - "];
    [out appendString:buildNumber.stringValue];
    return out;
}

/**
* Call this methods with current product version and build number strings extracted
* from the main bundle of the IOS application to detect an update of this program.
*/
- (void)detectNewVersion:(NSString *)currentVersion currentBuild:(NSString *)currentBuild delegate:(id /*<TwinkleDelegate>*/)delegate {
    // Get current values as integers
    NSArray *currentMajorMinor = [self convertToMajorMinor:currentVersion];
    NSNumber *currentBuildNumber = [NSNumber numberWithInteger:[currentBuild integerValue]];

    // Output current version as numbers
    NSLog(@"Current version %@", [self generateVersionString:currentMajorMinor buildNumber:currentBuildNumber]);

    // Fetch new version info
    NSURLRequest *request = [NSURLRequest requestWithURL:self.appPlistURL
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

    if ([response statusCode] == 200) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfURL:self.appPlistURL];
        NSArray *items = [dictionary objectForKey:@"items"];
        NSDictionary *metadata = [[items objectAtIndex:0] objectForKey:@"metadata"];
        _serverProductVersion = [metadata objectForKey:@"bundle-version"];
        _serverBuildNumber = [metadata objectForKey:@"bundle-build-number"];

        // Get new values as integers
        NSArray *newMajorMinor = [self convertToMajorMinor:self.serverProductVersion];
        NSNumber *newBuildNumber = [NSNumber numberWithInteger:[self.serverBuildNumber integerValue]];

        // Output current version as numbers
        NSLog(@"Version on server %@", [self generateVersionString:newMajorMinor buildNumber:newBuildNumber]);

        // Detect if new product version is bigger that current
        // new vs current
        // 1.3.3 is bigger than 1.3.2
        // 1.4 is bigger than 1.3.2
        // 2 is bigger than 1.3.2
        // 1.3.3 is bigger than 1.2
        // 1.3.3 is bigger than 1.3
        // 1.3 is bigger than 1
        bool newVersion = false;
        for (NSUInteger i = 0; i < newMajorMinor.count; i++) {
            NSNumber *a = [newMajorMinor objectAtIndex:i];
            NSNumber *b = [currentMajorMinor objectAtIndex:i];
            if ((i < currentMajorMinor.count && a.intValue > b.intValue) ||
                    (!newVersion && newMajorMinor.count > currentMajorMinor.count && i >= currentMajorMinor.count)) {
                newVersion = true;
            }
        }

        if (!newVersion && newMajorMinor.count == currentMajorMinor.count) {
            bool allEqual = false;
            for (NSUInteger i = 0; i < newMajorMinor.count; i++) {
                NSNumber *a = [newMajorMinor objectAtIndex:i];
                NSNumber *b = [currentMajorMinor objectAtIndex:i];
                if ([a intValue] == [b intValue]) {
                    allEqual = true;
                } else {
                    allEqual = false;
                }
            }
            if (allEqual && [newBuildNumber intValue] > [currentBuildNumber intValue]) {
                newVersion = true;
            }
        }

        if (newVersion) {
            _lastStatusMessage = [NSString stringWithFormat:@"New version %@", [self generateVersionString:newMajorMinor buildNumber:newBuildNumber]];
            [delegate newVersionDetected:_lastStatusMessage];
        } else {
            _lastStatusMessage = @"No new version detected";
        }

    } else {
        _lastStatusMessage = [NSString stringWithFormat:@"Contacting %@ resulted in statusCode = %i", self.appPlistURL, [response statusCode]];
    }
}

@end