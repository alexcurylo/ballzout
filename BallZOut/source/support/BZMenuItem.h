//
//  BZMenuItem.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 17/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//


#import <UIKit/UIKit.h>
#import "cocos2d.h"

enum {
   // same as kZoomActionTag internal to CCMenuItem.m
	kBZZoomActionTag = 0xc0c05002,
};

@interface BZMenuItem : CCMenuItemSprite
{
	float		originalScale_;
   
   id repeat_4ever_;
}

/** creates an initialize an item with Sprite Frame Names */
+(id) itemFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName target:(id)target selector:(SEL)selector;
+(id) itemFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName disabledSpriteFrameName:(NSString*)disabled target:(id)target selector:(SEL)selector;
/** creates an initialize an item with Sprite File Name */
+(id) itemFromNormalSpriteFileName:(NSString*)normalFileName target:(id)target selector:(SEL)selector;

/** initialize an item with Sprite Frame Names */
-(id) initFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName disabledSpriteFrameName:(NSString*)disabledSpriteFrameName target:(id)target selector:(SEL)selector;
-(id) initFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName target:(id)target selector:(SEL)selector;
/** initialize an item with Sprite File Name */
-(id) initFromNormalSpriteFileName:(NSString*)normalFileName target:(id)target selector:(SEL)selector;

- (void)startWaving;
- (void)stopWaving;

@end
