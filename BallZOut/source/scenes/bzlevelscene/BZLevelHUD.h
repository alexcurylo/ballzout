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

@class BZLevelScene;
//@class Joystick;
//@class JumpButton;

enum
{
   kColorLayerHeight = 40,
   
   // 1.0 shootForce is this many pixels wide
   kUnitForceWidth = 80,
   
   // and this is our default, 1/2 of screen
   kShootForceDefault = 2,
};

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


-(void) buttonRestart:(id)sender;

- (void)setShootForce:(float)newForce;
- (void)calculateShootForce:(CGPoint)viewLocation;

- (void)showActiveRing:(b2Vec2)around;
- (void)hideActiveRing;
- (BOOL)showingActiveRing;

@end
