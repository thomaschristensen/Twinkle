//
//  Twinkle.h
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

/**
 *  A small library to handle self updating of IOS Enterprise applications.
 *  The library compares the current application's version information with the
 *  new version's plist and pop up a notification to the viewer, potentially
 *  leading to the upgrade itself.
 *
 *  The library builds upon the principle of treating CFBundleShortVersionString as product version and
 *  CFBundleVersion as build number. Product versions are in the form of "x.y.z" and build numbers are integers.
 *  If this principle is not followed then the library will fail.
 */
@interface Twinkle : NSObject

/**
 The URL that points to the application plist on the web.

 This is typically specified during init of the object but can
 be safely changed between calls to detectNewVersion

 @see initWithAppPlistURL
 @see detectNewVersion
 */
@property (nonatomic, retain) NSURL* appPlistURL;

/**
 Contains the value of the product version found on the server
 specified by the appPlistURL.

 This value is available after calling detectNewVersion

 @see detectNewVersion
 */
@property (nonatomic, readonly) NSString* serverProductVersion;

/**
 Contains the value of the build number found on the server
 specified by the appPlistURL.

 This value is available after calling detectNewVersion

 @see detectNewVersion
 */
@property (nonatomic, readonly) NSString* serverBuildNumber;

/**
 Contains the status message from last call of detectNewVersion.

 @see detectNewVersion
 */
@property (nonatomic, readonly) NSString* lastStatusMessage;

/**
 Initialises an object with the specified Application Plist URL.

 @param appPlistURL points to a plist of this application on the web.
 */
- (id)initWithAppPlistURL:(NSURL *)appPlistURL;

/**
 Detects if there is a newer version available and call the delegate.

 @param detectNewVersion the product version of current application
 @param currentBuild the build number of current application
 @param delegate that will receive the callback if new version is detected.
 */
- (void)detectNewVersion:(NSString *)currentVersion currentBuild:(NSString *)currentBuild delegate:(id /*<TwinkleDelegate>*/)delegate;
@end