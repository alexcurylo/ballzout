//
//  BZScoreScene.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 07/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "cocos2d.h"
#import "SimpleAudioEngine.h"


@interface BZScoreScene : CCLayer
{
   //ALuint sfxID_;
	CDSoundSource* winSound;
}

+(id) scene;

-(void) wait1second:(ccTime)dt;
- (void)buttonContinue:(id)sender;

@end
