//
//  BZOptionsScene.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 07/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "cocos2d.h"

enum
{
   kSoundOffIndex = 0,
   kSoundOnIndex,

   kGameCenterOffIndex = 0,
   kGameCenterOnIndex,
};

@interface BZOptionsScene : CCLayer
{
   CCMenuItemToggle *itemGameCenterToggle_;
}

+ (id)scene;

- (id)init;
- (void)dealloc;

- (void)gameCenterEnableChanged:(NSNotification *)note;

- (void)buttonReturn:(id)sender;
- (void)buttonToggleSound:(id)sender;
- (void)buttonToggleGameCenter:(id)sender;

@end
