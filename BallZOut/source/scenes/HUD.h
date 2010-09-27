//
//  HUD.h
//  LevelSVG
//
//  Created by Ricardo Quesada on 16/10/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//

#import "cocos2d.h"

@class Joystick;
@class JumpButton;
@class GameNode;

@interface HUD : CCLayer {
	
	// game
	GameNode	*game;

	// joystick and joysprite. weak ref
	Joystick	*joystick;
	
	CCLabelBMFont	*score;
	CCLabelBMFont	*lives;
}

// creates and initializes a HUD
+(id) HUDWithGameNode:(GameNode*)game;

// initializes a HUD with a delegate
-(id) initWithGameNode:(GameNode*)game;

// display a message on the screen
-(void) displayMessage:(NSString*)message;

-(void) onUpdateScore:(int)newScore;

-(void) onUpdateLives:(int)newLives;


-(void) buttonRestart:(id)sender;

@end
