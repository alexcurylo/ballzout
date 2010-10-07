//
//  BZInstructionsScene.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 07/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BZLevelScene.h"

/*
 enum
{
   kTutorialStageCount = 3,
};
*/

@interface BZInstructionsScene : BZLevelScene
{
   BZGame *tutorial;
   NSInteger tutorialStage;
   NSMutableArray *bubbles;
   CCSprite *_trackingPowerSprite;
}

@property (nonatomic, retain) BZGame *tutorial;
@property (nonatomic, retain) NSMutableArray *bubbles;

#pragma mark -
#pragma mark Life cycle

//+ (id)scene;

- (id)init;
- (void)setupLevel;
- (void)dealloc;

#pragma mark -
#pragma mark Playing vs. Tutorial accessors

- (BZGame *)game;
- (BOOL)userPlaying;
// override to return to main
- (BOOL)mouseDown:(b2Vec2)p;
- (void)mouseUp:(b2Vec2)targetPosition;
// override to add drag tracking
- (void)update:(ccTime)dt;

#pragma mark -
#pragma mark Tutorial functions

- (void)gotoNextStage;
- (void)cleanBubbles;
- (void)addBubble:(NSString *)file x:(CGFloat)x y:(CGFloat)y;
- (void)addTapperFor:(CGFloat)windup x:(CGFloat)x y:(CGFloat)y;
- (void)tapWindupEnd:(CCSprite *)tapper;
- (void)addDraggerFor:(CGFloat)windup x:(CGFloat)x y:(CGFloat)y;
- (void)dragWindupEnd:(CCSprite *)dragger;

#pragma mark -
#pragma mark User actions

- (void)buttonReturn:(id)sender;
- (void)buttonBubble:(id)sender;

@end
