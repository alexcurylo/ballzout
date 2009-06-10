//
//  TWProjectPrefix.h
//
//  Copyright 2009 Trollwerks Inc. All rights reserved.
//

#import <Availability.h>
#import <TargetConditionals.h>

// define our own TWTARGET_SDK_[IPHONE|MAC] and TWTARGET_RT_[DEVICE|SIMULATOR]
#if TARGET_OS_IPHONE
#define TWTARGET_SDK_IPHONE 1
#if TARGET_IPHONE_SIMULATOR
#define TWTARGET_RT_SIMULATOR 1
#else
#define TWTARGET_RT_DEVICE 1
#endif TARGET_IPHONE_SIMULATOR
#else
#define TWTARGET_SDK_MAC 1
#endif TARGET_OS_IPHONE

// this will be set if ActiveSDK selection is 3.0 or greater
#define TWTARGET_SDKVERSION_3 __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000

#import <TWDebugging.h>

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#endif __OBJC__
