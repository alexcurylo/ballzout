//
//  BZLevelHUD.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 16/10/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//

//
// BZLevelHUD: Head Up Display
//
// - Display score
// - Display lives
// - Display joystick, but it is not responsible for reading it
// - Display the menu button
// - Register a touch events: drags the screen
//

#import "BZLevelHUD.h"
#import "BZMainScene.h"
#import "BZLevelScene.h"
#import "SimpleAudioEngine.h"
#import "BallZOutAppDelegate.h"
#import "BZMenuItem.h"

//#import "GameConfiguration.h"
//import "Joystick.h"
//#import "GameNode.h"
//#import "MenuScene.h"
//#import "HelloWorldScene.h"
//#import "Hero.h"

@implementation BZLevelHUD

@synthesize shootForce;

+ (id)BZLevelHUDWithLevelScene:(BZLevelScene*)game
{
	return [[[self alloc] initWithLevelScene:game] autorelease];
}

- (id)initWithLevelScene:(BZLevelScene *)aGame
{
	if ( (self=[super init]))
   {
		
		self.isTouchEnabled = YES;
		game = aGame;

		CGSize s = [[CCDirector sharedDirector] winSize];
      
      /*
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
       */
		
		//CCColorLayer *color = [CCColorLayer layerWithColor:ccc4(32,32,32,128) width:s.width height:kColorLayerHeight];
		// we want top portion to not be part of game
      CCColorLayer *color = [CCColorLayer layerWithColor:ccc4(32,32,32,255) width:s.width height:kColorLayerHeight];
		[color setPosition:ccp(0,s.height-kColorLayerHeight)];
		[self addChild:color z:0];
		
      forceLayer = [CCColorLayer layerWithColor:ccc4(255,0,0,128) width:s.width height:kColorLayerHeight];
		[forceLayer setPosition:ccp(0,s.height-kColorLayerHeight)];
		[self addChild:forceLayer z:1];

		// Menu Button
		//CCMenuItem *itemPause = [CCMenuItemImage itemFromNormalImage:@"btn-pause-normal.png" selectedImage:@"btn-pause-selected.png" target:self selector:@selector(buttonPause:)];
      BZMenuItem *itemPause = [BZMenuItem
         itemFromNormalSpriteFrameName:@"pauseclock32.png"
         selectedSpriteFrameName:nil
         target:self
         selector:@selector(buttonPause:)
         ];
      CCMenu *menu = [CCMenu menuWithItems:itemPause,(id)nil];
		[self addChild:menu z:1];
		[menu setPosition:ccp(20,s.height-20)];
		
		// Score Label
      /*
		CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:@"SCORE:" fntFile:@"gas32.fnt"];
		[scoreLabel.texture setAliasTexParameters];
		[self addChild:scoreLabel z:1];
		[scoreLabel setPosition:ccp(s.width/2+0.5f-45, s.height-20.5f)];
		*/
      CCSprite	*scoreLabel = [CCSprite spriteWithSpriteFrameName:@"trophy28.png"];
		[self addChild:scoreLabel z:1];
		[scoreLabel setAnchorPoint:ccp(0,0.5f)];
		[scoreLabel setPosition:ccp(75, s.height-20.5f)];		
      
		// Score Points
      NSString *scoreText = [NSString stringWithFormat:@"%d", BZCurrentGame().score];
		score = [CCLabelBMFont labelWithString:scoreText fntFile:@"bubblegum.fnt"];
//		[score.texture setAliasTexParameters];
		[self addChild:score z:1];
		//[score setPosition:ccp(s.width/2+0.5f+25, s.height-20.5f)];
		[score setAnchorPoint:ccp(0,0.5f)];
		[score setPosition:ccp(100, s.height-20.5f)];		
		
		// Lives label
      /*
		CCLabelBMFont *livesLabel = [CCLabelBMFont labelWithString:@"LIVES:" fntFile:@"gas32.fnt"];
		[lives.texture setAliasTexParameters];
		[self addChild:livesLabel z:1];
		[livesLabel setAnchorPoint:ccp(1,0.5f)];
		[livesLabel setPosition:ccp(s.width-5.5f-20, s.height-20.5f)];		
       */
      //CCSpriteFrame *livesFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"heart36.png"];
      CCSprite	*livesLabel = [CCSprite spriteWithSpriteFrameName:@"heart28.png"];
		[self addChild:livesLabel z:1];
		[livesLabel setAnchorPoint:ccp(1,0.5f)];
		[livesLabel setPosition:ccp(s.width-5.5f-20, s.height-20.5f)];		
	
		lives = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%d", BZCurrentGame().lives] fntFile:@"bubblegum.fnt"];
		[lives.texture setAliasTexParameters];
		[self addChild:lives z:1];
		[lives setAnchorPoint:ccp(1,0.5f)];
		[lives setPosition:ccp(s.width-5.5f, s.height-20.5f)];		
      
      // active ring
      CCSpriteFrame *ringFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"circle-yellow-for48.png"];
      activeRing_ = [CCSprite spriteWithSpriteFrame:ringFrame];
      activeRing_.visible = NO;
		[self addChild:activeRing_ z:1];
      id rot1 = [CCRotateBy actionWithDuration:2 angle:360];
      id repeat_4ever = [CCRepeatForever actionWithAction:rot1];
      [activeRing_ runAction:repeat_4ever];

      self.shootForce = kShootForceDefault;
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
   
   message = NSLocalizedString(message, nil);
	
	CCLabelTTF *label = [CCLabelTTF labelWithString:message fontName:@"Marker Felt" fontSize:54];
	[self addChild:label];
	[label setPosition:ccp(s.width/2, s.height/2)];

	id sleep = [CCDelayTime actionWithDuration:3];
	id rot1 = [CCRotateBy actionWithDuration:0.2f angle:5];
	id rot2 = [CCRotateBy actionWithDuration:0.4f angle:-10];
	id rot3 = [rot2 reverse];
	id rot4 = [rot1 reverse];
	id seq = [CCSequence actions:rot1, rot2, rot3, rot4, (id)nil];
	id repeat_rot = [CCRepeat actionWithAction:seq times:3];
	
	id big_seq = [CCSequence actions:sleep, repeat_rot, (id)nil];
	id repeat_4ever = [CCRepeatForever actionWithAction:big_seq];
	[label runAction:repeat_4ever];
	
}

- (void)buttonPause:(id)sender
{
   (void)sender;
   
   // could be already paused, or finished
   if (kLevelStatePlaying != game.levelState)
      return;
   
   [game setPaused:YES];
    
	[[SimpleAudioEngine sharedEngine] playEffect:@"pause.wav"];

   BZMenuItem *itemContinue = [BZMenuItem
      itemFromNormalSpriteFrameName:@"button_continue.png"
      selectedSpriteFrameName:nil
      target:self
      selector:@selector(buttonContinue:)
      ];
   [itemContinue startWaving];
   BZMenuItem *itemQuit = [BZMenuItem
      itemFromNormalSpriteFrameName:@"button_quit.png"
      selectedSpriteFrameName:nil
      target:self
      selector:@selector(buttonQuit:)
      ];
   pauseMenu_ = [CCMenu menuWithItems:
       itemContinue,
       itemQuit,
       (id)nil
       ];
   //[pauseMenu_ setPosition:ccp(0,0)];
   [self addChild:pauseMenu_ z:100];
   [pauseMenu_ alignItemsVertically];
}

- (void)buttonContinue:(id)sender
{
   (void)sender;

   [pauseMenu_ removeFromParentAndCleanup:YES];
   pauseMenu_ = nil;
   
   [game setPaused:NO];
}

- (void)buttonQuit:(id)sender
{
   (void)sender;
   
	//[[SimpleAudioEngine sharedEngine] playEffect:@"buttonpush.wav"];

	//[[CCDirector sharedDirector] replaceScene: [CCTransitionCrossFade transitionWithDuration:1 scene:[MenuScene scene]]];
	//[[CCDirector sharedDirector] replaceScene: [CCTransitionCrossFade transitionWithDuration:1 scene:[HelloWorld scene]]];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionCrossFade transitionWithDuration:1 scene:[BZMainScene scene]]];
}

- (void) dealloc
{
	[super dealloc];
}

 - (void)setShootForce:(float)newForce
{
   shootForce = MAX(0, newForce);

   float forceWidth = shootForce * kUnitForceWidth;
   [forceLayer changeWidth:forceWidth];
}

- (void)calculateShootForce:(CGPoint)viewLocation
{
   //twlog("calculateShootForce: %@", NSStringFromCGPoint(viewLocation));

   // note assumption forceLayer begins at 0
   float newForce = viewLocation.x / kUnitForceWidth;
   
   self.shootForce = newForce;
}

- (void)showActiveRing:(b2Vec2)around
{
   CGPoint where = {
      around.x * kPhysicsPTMRatio,
      around.y * kPhysicsPTMRatio,
   };
   activeRing_.position = where;
   activeRing_.visible = YES;
}

- (void)hideActiveRing
{
   activeRing_.visible = NO;
}

- (BOOL)showingActiveRing
{
   return activeRing_.visible;
}

#pragma mark Touch Handling

-(void) registerWithTouchDispatcher
{
	// Priorities: lower number, higher priority
	// Joystick: 10
	// GameNode (dragging objects): 50
	// BZLevelHUD (dragging screen): 100
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kPriorityShootForce swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
   (void)event;
   
   CGPoint touchLocation=[touch locationInView:[touch view]];
   
   // note assumption forceLayer extends from top of screen
   if (touchLocation.y > forceLayer.contentSize.height)
      return NO;

   [self calculateShootForce:touchLocation];

	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
   (void)event;
   
   CGPoint touchLocation=[touch locationInView:[touch view]];
   [self calculateShootForce:touchLocation];
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
   (void)touch;
   (void)event;
   twlog("BZLevelHUD ccTouchCancelled!!");
}

// drag the screen
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
   (void)event;
   
   CGPoint touchLocation=[touch locationInView:[touch view]];
   [self calculateShootForce:touchLocation];
   /*
 CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
	
	CGPoint diff = ccpSub(touchLocation,prevLocation);
	game.cameraOffset = ccpAdd( game.cameraOffset, diff );
 */
}

@end
