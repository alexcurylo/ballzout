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
};

@interface BZOptionsScene : CCLayer
{
}

+(id) scene;

- (void)buttonReturn:(id)sender;
- (void)buttonToggleSound:(id)sender;

@end
