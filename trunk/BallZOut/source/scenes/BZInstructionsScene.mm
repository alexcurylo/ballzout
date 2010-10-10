//
//  BZInstructionsScene.m
//  LevelSVG
//
//  Created by Ricardo Quesada on 07/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


#import "BZInstructionsScene.h"
#import "BZMainScene.h"
#import "BZSimpleButton.h"
#import "SimpleAudioEngine.h"
#import "BallZOutAppDelegate.h"
#import "BZMenuItem.h"
#import "BZLevelHUD.h"

//
// This is an small Scene that makes the trasition smoother from the Defaul.png image to the menu scene
//

@implementation BZInstructionsScene

@synthesize tutorial;
@synthesize bubbles;

#pragma mark -
#pragma mark Life cycle

/* unnecessary, [BZLevelScene scene] calls [self node] so it'll initialize us properly
+ (id)scene
{
	CCScene *scene = [CCScene node];
	id node = [BZInstructionsScene node];
	[s addChild:node];
	return scene;
}
*/

- (id)init
{
	if ( (self = [super init]) )
   {
      self.tutorial = [[[BZGame alloc] init] autorelease];
      self.tutorial.isTutorial = YES;
      
      self.bubbles = [NSMutableArray array];
      
      // all other setup deferred to after BZLevelScene does -setupLevel with -game now working
	}
   
	return self;
}

- (void)setupLevel
{
   [super setupLevel];
      
   // Load all the sprites/platforms now
   //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
   //[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];
   
   /*
   CGSize size = [[CCDirector sharedDirector] winSize];
   CCSprite *background = [CCSprite spriteWithFile:@"scene-options.jpg"];
   //background.rotation = -90;
   background.position = ccp(size.width/2, size.height/2);
   [self addChild:background];
    */
   
   /*
   BZSimpleButton *itemReturn = [BZSimpleButton
      simpleButtonAtPosition:ccp(kPositionLeftScreenEdge, kPositionTopScreenEdge)
      imageFile:@"button_returnarrow.png"
      target:self
      selector:@selector(buttonReturn:)
      ];
   [self addChild:itemReturn z:5];
   */
   
   //[self schedule:@selector(wait1second:) interval:1];
   //[[SimpleAudioEngine sharedEngine] playEffect:@"gamewin.caf"];
   
   [self gotoNextStage];
}

- (void)dealloc
{
   twrelease(tutorial);
   twrelease(bubbles);
   
   [super dealloc];
}

#pragma mark -
#pragma mark Playing vs. Tutorial accessors

- (BZGame *)game
{
   return self.tutorial;
}

- (BOOL)userPlaying
{
   return NO;
}

// override to return to main

- (BOOL)mouseDown:(b2Vec2)p
{
   (void)p;
   // anything outside a bubble is return to main
   return YES;
}

- (void)mouseUp:(b2Vec2)targetPosition
{
   (void)targetPosition;
   // anything outside a bubble is return to main
   [self buttonReturn:nil];
}

- (void)update:(ccTime)dt
{
   [super update:dt];
   
   if (_trackingPowerSprite)
   {
      CGPoint touchLocation = _trackingPowerSprite.position;
      [self.hud calculateShootForce:touchLocation];
   }
}

#pragma mark -
#pragma mark Tutorial functions

- (void)gotoNextStage
{
   // clean up last stage bubbles
   
   [self cleanBubbles];

   // increment stage, see if we're finished
   
   tutorialStage++;
   CGSize size = [CCDirector sharedDirector].winSize;
   /*
   if (kTutorialStageCount < tutorialStage)
   {
      BZSimpleButton *itemFinished = [BZSimpleButton
         simpleButtonAtPosition:ccp(size.width/2, size.height/2)
         imageFile:@"99finished.png"
         target:self
         selector:@selector(buttonReturn:)
      ];
      [self addChild:itemFinished z:25];
      return;
   }
   */
   
   // ok, set up bubbles for this stage
   
   switch (tutorialStage)
   {
      case 1:
         [self addBubble:@"01welcome.png" x:(size.width/2) - 25 y:333];
         [self addBubble:@"01proceed.png" x:(size.width/2) y:220];
         break;
      case 2:
         [self addBubble:@"02notyours.png" x:(size.width/2) - 17 y:230];
         [self addBubble:@"02yours.png" x:(size.width/2) + 23 y:106];
         break;
      case 3:
         [self addBubble:@"03pause.png" x:(size.width/2) - 67 y:264];
         [self addBubble:@"03lives.png" x:(size.width/2) + 57 y:312];
         [self addBubble:@"03score.png" x:(size.width/2) - 45 y:360];
         break;
      case 4:
         [self addBubble:@"04selected.png" x:(size.width/2) - 15 y:183];
         [self addBubble:@"04select.png" x:(size.width/2) + 40 y:115];
         break;
      case 5:
         [self addBubble:@"05careful.png" x:(size.width/2) + 40 y:125];
         break;
      case 6:
         [self addBubble:@"06obstacles.png" x:(size.width/2) + 20 y:220];
         break;
      case 7:
         [self addBubble:@"07hold.png" x:(size.width/2) - 5 y:135];
         [self addBubble:@"07power.png" x:(size.width/2) - 15 y:315];
         [self addDraggerFor:1.75 x:190 y:420];
         break;
         
      default:
         BZSimpleButton *itemFinished = [BZSimpleButton
            simpleButtonAtPosition:ccp(size.width/2, size.height/2)
            imageFile:@"99finished.png"
            target:self
            selector:@selector(buttonReturn:)
         ];
         [self addChild:itemFinished z:75];
         break;
   }
}

- (void)cleanBubbles
{
   //[self.hud stopTrackingPowerNode];
   _trackingPowerSprite = nil;
   
   for (BZSimpleButton *bubble in self.bubbles)
   {
      if (kTutorialStageCount <= tutorialStage)
      {
         // saw some irreproducible crashes as #7's were almost offscreen,
         // guessing that was due to scene end timing although it doesn't seem
         // to happen when interrupted in mid-tutorial? so we'll just remove those.
         [bubble removeFromParentAndCleanup:YES];
         continue;
      }
      id scaleBack = [CCScaleTo actionWithDuration:0.3f scale:.1f];
      id done = [CCCallFuncN actionWithTarget:self selector:@selector(bubbleCleaned:)];
      id seq = [CCSequence actions:scaleBack, done, (id)nil];
      [bubble runAction:seq];
   }
   
   [self.bubbles removeAllObjects];
}

- (void)bubbleCleaned:(CCNode *)bubble
{
   [bubble removeFromParentAndCleanup:YES];
}

- (void)addBubble:(NSString *)file x:(CGFloat)x y:(CGFloat)y
{
   BZSimpleButton *bubble = [BZSimpleButton
      simpleButtonAtPosition:ccp(x, y)
      imageFile:file
      target:self
      selector:@selector(buttonBubble:)
      ];
   [bubble setScale:.1f];
   [bubble runAction:[CCScaleTo actionWithDuration:0.3f scale:1]];
   [self addChild:bubble z:75];
   [self.bubbles addObject:bubble];
}

- (void)addTapperFor:(CGFloat)windup x:(CGFloat)x y:(CGFloat)y
{
   [self cleanBubbles];

   CCSprite	*tapper = [CCSprite spriteWithSpriteFrameName:@"sprite-hand.png"];
   [self addChild:tapper z:55];
   [tapper setAnchorPoint:ccp(0.32, 0.8)];		
   [tapper setPosition:ccp(x, y)];		

   id blink = [CCBlink actionWithDuration:windup blinks:7];
   id launch = [CCCallFuncN actionWithTarget:self selector:@selector(tapWindupEnd:)];
   id sleep = [CCDelayTime actionWithDuration:0.2];
   id fade = [CCFadeTo actionWithDuration:3.9 opacity:20];
   id next = [CCCallFunc actionWithTarget:self selector:@selector(gotoNextStage)];
	id sequence = [CCSequence actions:blink, launch, sleep, fade, next, (id)nil];
   [tapper runAction:sequence];
   
   [self.bubbles addObject:tapper];
}

- (void)tapWindupEnd:(CCSprite *)tapper
{
   CGPoint touchLocation = tapper.position;
	/*
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    CGPoint nodePosition = [self convertToNodeSpace:touchLocation];
    [super mouseUp: b2Vec2(nodePosition.x/kPhysicsPTMRatio,nodePosition.y/kPhysicsPTMRatio)];
    */
   [super mouseUp: b2Vec2(touchLocation.x/kPhysicsPTMRatio,touchLocation.y/kPhysicsPTMRatio)];
}

- (void)addDraggerFor:(CGFloat)windup x:(CGFloat)x y:(CGFloat)y
{
   CCSprite	*dragger = [CCSprite spriteWithSpriteFrameName:@"sprite-hand.png"];
   [self addChild:dragger z:55];
   [dragger setAnchorPoint:ccp(0.32, 0.8)];		
   [dragger setPosition:ccp(x, y)];		
   
   id blink = [CCBlink actionWithDuration:windup blinks:7];
   id launch = [CCCallFuncN actionWithTarget:self selector:@selector(dragWindupEnd:)];
	id sequence = [CCSequence actions:blink, launch, (id)nil];
   [dragger runAction:sequence];

   [self.bubbles addObject:dragger];
}

- (void)dragWindupEnd:(CCSprite *)dragger
{
   _trackingPowerSprite = dragger;
   
   CGPoint touchLocation = _trackingPowerSprite.position;
   [self.hud calculateShootForce:touchLocation];

   const float kWobble = 100;
   id moveRight = [CCMoveBy actionWithDuration:1.0 position:ccp(kWobble, 0)];
   id moveLeft = [CCMoveBy actionWithDuration:2.0 position:ccp(-2 * kWobble, 0)];
   id moveStart = [CCMoveBy actionWithDuration:1.0 position:ccp(kWobble, 0)];
   id wobble = [CCSequence actions:moveRight, moveLeft, moveStart, (id)nil];
   id repeat = [CCRepeatForever actionWithAction:wobble];
   [dragger runAction:repeat];
}

#pragma mark -
#pragma mark User actions

- (void)buttonReturn:(id)sender
{
   (void)sender;
   id destinationScene = [BZMainScene scene];
	// nope, that uggily shows sprites out of bounds
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionMoveInR transitionWithDuration:1.0f scene:destinationScene]];
	[[CCDirector sharedDirector] replaceScene:[CCTransitionTurnOffTiles transitionWithDuration:0.25f scene:destinationScene]];
}   

- (void)buttonBubble:(id)sender;
{
   (void)sender;
   
   switch (tutorialStage)
   {
      case 1:
      case 2:
      case 3:
      case 6:
      case 7:
         [self gotoNextStage];
         break;
      case 4:
         [self addTapperFor:1.75 x:120 y:240];
         break;
      case 5:
         [self addTapperFor:1.75 x:289 y:85];
         break;
         
      default:
         twlog("unhandled stage in buttonBubble!");
         break;
   }
}
   
@end
