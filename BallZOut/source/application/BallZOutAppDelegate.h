//
//  BallZOutAppDelegate.h
//  BallZOut
//
//  Created by alex on 10-09-24.
//  Copyright Trollwerks Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface BallZOutAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end

#pragma mark -
#pragma mark Conveniences

BallZOutAppDelegate *TWAppDelegate(void);
