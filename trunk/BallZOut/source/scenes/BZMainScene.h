//
//  BZMainScene.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "cocos2d.h"

@class BZSimpleButton;

@interface BZMainScene : CCLayer
{
   //BZSimpleButton *itemPlay_;
}

+ (id)scene;

- (void)loadSpritesAndSounds:(ccTime)dt;
//- (void)startWaving:(ccTime)dt;
- (void)wait1second:(ccTime)dt;

- (void)buttonPlayGame:(id)sender;
- (void)buttonInstructions:(id)sender;
- (void)buttonOptions:(id)sender;
- (void)buttonLeaderboard:(id)sender;
- (void)buttonAchievements:(id)sender;
- (void)buttonMoreGames:(id)sender;


@end
