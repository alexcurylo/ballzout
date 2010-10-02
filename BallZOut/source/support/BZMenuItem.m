//
//  BZMenuItem.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 17/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION
//


#import "BZMenuItem.h"
#import "SimpleAudioEngine.h"

//
// A MeneItem that plays a sound each time is is pressed
// Added support for SpriteFrameNames
//
@implementation BZMenuItem

+(id) itemFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initFromNormalSpriteFrameName:normalFrameName selectedSpriteFrameName:selectedFrameName disabledSpriteFrameName:nil target:target selector:selector] autorelease];
}

+(id) itemFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selected disabledSpriteFrameName:(NSString*)disabled target:(id)target selector:(SEL)selector
{
	return [[[self alloc] initFromNormalSpriteFrameName:normalFrameName selectedSpriteFrameName:selected disabledSpriteFrameName:disabled target:target selector:selector] autorelease];
}

-(id) initFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName target:(id)target selector:(SEL)selector
{
	return [self initFromNormalSpriteFrameName:normalFrameName selectedSpriteFrameName:selectedFrameName disabledSpriteFrameName:nil target:target selector:selector];
}


-(id) initFromNormalSpriteFrameName:(NSString*)normalFrameName selectedSpriteFrameName:(NSString*)selectedFrameName disabledSpriteFrameName:(NSString*)disabledFrameName target:(id)target selector:(SEL)selector
{
	CCSprite *normalSprite = [CCSprite spriteWithSpriteFrameName:normalFrameName];
	CCSprite *selected = selectedFrameName.length ? [CCSprite spriteWithSpriteFrameName:selectedFrameName] : normalSprite;
	
	CCSprite *disabled = nil;
	if( disabledFrameName )
		disabled = [CCSprite spriteWithSpriteFrameName:disabledFrameName];
				
	if( (self=[super initFromNormalSprite:normalSprite selectedSprite:selected disabledSprite:disabled target:target selector:selector]))
	{
		originalScale_ = 1;

      // noooo, this makes it go black like adding to BZSimpleButton does
	   //id playAction = [CCLiquid actionWithWaves:4 amplitude:2.0 grid:ccg(8,8) duration:15];
      //[self runAction:[CCRepeatForever actionWithAction:playAction]];
      
   }
   
	return self;	
}

-(void) activate
{
	if (isEnabled_)
   {
		[self stopAllActions];
      
		self.scale = originalScale_;
   }

   [super activate];
}

- (void)selected
{
	[super selected];
   
   // as from CCMenuItemLabel
	if (isEnabled_)
   {	
		[self stopActionByTag:kBZZoomActionTag];
		originalScale_ = self.scale;
		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:originalScale_ * 1.2f];
		zoomAction.tag = kBZZoomActionTag;
		[self runAction:zoomAction];
	}
   
	[[SimpleAudioEngine sharedEngine] playEffect:@"buttonpush.wav"];
}

- (void)unselected
{
	[super unselected];

   if (isEnabled_)
   {
		[self stopActionByTag:kBZZoomActionTag];
		CCAction *zoomAction = [CCScaleTo actionWithDuration:0.1f scale:originalScale_];
		zoomAction.tag = kBZZoomActionTag;
		[self runAction:zoomAction];
	}
}

- (void)startWaving
{
   /*
    // skips uggily if we do this before loading? Or in loading? Noooo, always it seems...
    // this makes background go black if we apply it to just play game ... so let's apply it to the whole scene!
    id playAction = [CCLiquid actionWithWaves:4 amplitude:2.0 grid:ccg(8,8) duration:15];
    //id playAction = [CCWaves3D actionWithWaves: 4 amplitude: 40 grid: ccg(15,10) duration: 15];
    //id playAction = [CCShaky3D actionWithRange:4 shakeZ:NO grid:ccg(15,10) duration:5];
    [self runAction:[CCRepeatForever actionWithAction:playAction]];
    */
   
   id sleep = [CCDelayTime actionWithDuration:3];
	id rot1 = [CCRotateBy actionWithDuration:0.025f angle:5];
	id rot2 = [CCRotateBy actionWithDuration:0.05f angle:-10];
	id rot3 = [rot2 reverse];
	id rot4 = [rot1 reverse];
	id seq = [CCSequence actions:rot1, rot2, rot3, rot4, (id)nil];
	id repeat_rot = [CCRepeat actionWithAction:seq times:3];
	id big_seq = [CCSequence actions:sleep, repeat_rot, (id)nil];
	id repeat_4ever = [CCRepeatForever actionWithAction:big_seq];
	[self runAction:repeat_4ever];
}

@end
