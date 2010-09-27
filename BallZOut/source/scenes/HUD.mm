//
//  HUD.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 16/10/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//

//
// HUD: Head Up Display
//
// - Display score
// - Display lives
// - Display joystick, but it is not responsible for reading it
// - Display the menu button
// - Register a touch events: drags the screen
//

#import "HUD.h"
#import "GameConfiguration.h"
#import "Joystick.h"
#import "GameNode.h"
//#import "MenuScene.h"
#import "HelloWorldScene.h"
#import "Hero.h"

@implementation HUD

+(id) HUDWithGameNode:(GameNode*)game
{
	return [[[self alloc] initWithGameNode:game] autorelease];
}
-(id) initWithGameNode:(GameNode*)aGame
{
	if( (self=[super init])) {
		
		self.isTouchEnabled = YES;
		game = aGame;

		CGSize s = [[CCDirector sharedDirector] winSize];

		// level control configuration:
		//  - 2-way or 4-way ?
		//  - d-pad or accelerometer ?
		//  - 0, 1 or 2 buttons ?
	
		GameConfiguration *config = [GameConfiguration sharedConfiguration];
		ControlType control = [config controlType];
		ControlButton button = [config controlButton];
		
		joystick = [Joystick joystick];
		[self addChild:joystick];

		switch (button) {
			case kControlButton0:
				[joystick setButton:BUTTON_A enabled:NO];
			case kControlButton1:
				[joystick setButton:BUTTON_B enabled:NO];
				break;
			case kControlButton2:
				// both buttons are enabled by default, no need to modify it
				break;
		}
		
		// The Hero is responsible for reading the joystick
		[[game hero] setJoystick:joystick];		
		
		// enable button left/right only if using "Pad" controls
		
		[joystick setPadEnabled: NO];
		// pad + 4 direction is not implemented yet
		if( control==kControlTypePad) {

			[joystick setPadEnabled: YES];
			[joystick setPadPosition:ccp(74,74)];
		}
		
		CCColorLayer *color = [CCColorLayer layerWithColor:ccc4(32,32,32,128) width:s.width height:40];
		[color setPosition:ccp(0,s.height-40)];
		[self addChild:color z:0];
		
		// Menu Button
		CCMenuItem *itemPause = [CCMenuItemImage itemFromNormalImage:@"btn-pause-normal.png" selectedImage:@"btn-pause-selected.png" target:self selector:@selector(buttonRestart:)];
		CCMenu *menu = [CCMenu menuWithItems:itemPause,(id)nil];
		[self addChild:menu z:1];
		[menu setPosition:ccp(20,s.height-20)];
		
		// Score Label
		CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:@"SCORE:" fntFile:@"gas32.fnt"];
		[scoreLabel.texture setAliasTexParameters];
		[self addChild:scoreLabel z:1];
		[scoreLabel setPosition:ccp(s.width/2+0.5f-45, s.height-20.5f)];
		
		// Score Points
		score = [CCLabelBMFont labelWithString:@"000" fntFile:@"gas32.fnt"];
//		[score.texture setAliasTexParameters];
		[self addChild:score z:1];
		[score setPosition:ccp(s.width/2+0.5f+25, s.height-20.5f)];
		
		// Lives label
		CCLabelBMFont *livesLabel = [CCLabelBMFont labelWithString:@"LIVES:" fntFile:@"gas32.fnt"];
		[lives.texture setAliasTexParameters];
		[self addChild:livesLabel z:1];
		[livesLabel setAnchorPoint:ccp(1,0.5f)];
		[livesLabel setPosition:ccp(s.width-5.5f-20, s.height-20.5f)];		
		
		lives = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", game.lives] fntFile:@"gas32.fnt"];
		[lives.texture setAliasTexParameters];
		[self addChild:lives z:1];
		[lives setAnchorPoint:ccp(1,0.5f)];
		[lives setPosition:ccp(s.width-5.5f, s.height-20.5f)];		
		
	}
	
	return self;
}

-(void) onUpdateScore:(int)newScore
{
	[score setString: [NSString stringWithFormat:@"%03d", newScore]];
	[score stopAllActions];
	id scaleTo = [CCScaleTo actionWithDuration:0.1f scale:1.2f];
	id scaleBack = [CCScaleTo actionWithDuration:0.1f scale:1];
	id seq = [CCSequence actions:scaleTo, scaleBack, (id)nil];
	[score runAction:seq];
}

-(void) onUpdateLives:(int)newLives
{
	[lives setString: [NSString stringWithFormat:@"%d", newLives]];
	[lives runAction:[CCBlink actionWithDuration:0.5f blinks:5]];
}

-(void) displayMessage:(NSString*)message
{
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	CCLabelTTF *label = [CCLabelTTF labelWithString:message fontName:@"Marker Felt" fontSize:54];
	[self addChild:label];
	[label setPosition:ccp(s.width/2, s.height/2)];

	id sleep = [CCDelayTime actionWithDuration:3];
	id rot1 = [CCRotateBy actionWithDuration:0.025f angle:5];
	id rot2 = [CCRotateBy actionWithDuration:0.05f angle:-10];
	id rot3 = [rot2 reverse];
	id rot4 = [rot1 reverse];
	id seq = [CCSequence actions:rot1, rot2, rot3, rot4, (id)nil];
	id repeat_rot = [CCRepeat actionWithAction:seq times:3];
	
	id big_seq = [CCSequence actions:sleep, repeat_rot, (id)nil];
	id repeat_4ever = [CCRepeatForever actionWithAction:big_seq];
	[label runAction:repeat_4ever];
	
}

-(void) buttonRestart:(id)sender
{
   (void)sender;
   twlog("buttonRestart should do something!");
	//[[CCDirector sharedDirector] replaceScene: [CCTransitionCrossFade transitionWithDuration:1 scene:[MenuScene scene]]];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionCrossFade transitionWithDuration:1 scene:[HelloWorld scene]]];
}

- (void) dealloc
{
	[super dealloc];
}


#pragma mark Touch Handling

-(void) registerWithTouchDispatcher
{
	// Priorities: lower number, higher priority
	// Joystick: 10
	// GameNode (dragging objects): 50
	// HUD (dragging screen): 100
	//[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:100 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
   (void)touch;
   (void)event;
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
   (void)touch;
   (void)event;
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
   (void)touch;
   (void)event;
}

// drag the screen
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
   (void)event;
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
	
	CGPoint diff = ccpSub(touchLocation,prevLocation);
	game.cameraOffset = ccpAdd( game.cameraOffset, diff );
}

@end
