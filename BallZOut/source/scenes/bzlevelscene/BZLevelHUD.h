//
//  BZLevelHUD.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 16/10/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//

#import "cocos2d.h"
#import "Box2D.h"
#import "BZLevelConstants.h"

@class BZLevelScene;

#define kColorLayerHeight kTopHUDHeight
// 1.0 shootForce is this many pixels wide
#define kUnitForceWidth (55.f)
// and this is our default, 1/2 of screen
#define kShootForceDefault (3.f)

@interface BZLevelHUD : CCLayer
{
	
	// game
	BZLevelScene	*game;

	// joystick and joysprite. weak ref
	//Joystick	*joystick;
   CCSprite	*activeRing_;

	CCLabelBMFont	*score;
	CCLabelBMFont	*lives;
   
   float shootForce;
   CCColorLayer *forceLayer;
   
   CCMenu *pauseMenu_;
}

@property (readwrite,nonatomic) float shootForce;

// creates and initializes a BZLevelHUD
+(id) BZLevelHUDWithLevelScene:(BZLevelScene *)game;

// initializes a BZLevelHUD with a delegate
-(id) initWithLevelScene:(BZLevelScene *)game;

// display a message on the screen
-(void) displayMessage:(NSString*)message;

-(void) onUpdateScore:(int)newScore;

-(void) onUpdateLives:(int)newLives;


-(void) buttonPause:(id)sender;
-(void) buttonContinue:(id)sender;
-(void) buttonQuit:(id)sender;

- (void)setShootForce:(float)newForce;
- (void)calculateShootForce:(CGPoint)viewLocation;

- (void)showActiveRing:(b2Vec2)around;
- (void)hideActiveRing;
- (BOOL)showingActiveRing;

@end
