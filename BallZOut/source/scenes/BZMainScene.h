//
//  BZMainScene.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "cocos2d.h"

@class BZSimpleButton;

@interface BZMainScene : CCLayer
{
   BZSimpleButton *itemPlay_;
   BOOL itemPlayWaving;
}

+ (id)scene;

- (void)dealloc;
- (void)loadSpritesAndSounds:(ccTime)dt;
//- (void)startWaving:(ccTime)dt;
//- (void)wait1second:(ccTime)dt;
//- (void)onEnterTransitionDidFinish;
- (void)waveIfSafe;
- (void)gameCenterLoginResolved:(NSNotification *)note;

- (void)buttonPlayGame:(id)sender;
- (void)buttonNewGame:(id)sender;
- (void)buttonContinueGame:(id)sender;
- (void)buttonInstructions:(id)sender;
- (void)buttonOptions:(id)sender;
- (void)buttonLeaderboard:(id)sender;
- (void)buttonAchievements:(id)sender;
- (void)buttonMoreGames:(id)sender;


@end
