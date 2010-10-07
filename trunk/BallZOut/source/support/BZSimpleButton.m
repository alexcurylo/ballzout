//
//  BZSimpleButton.m
//
//  Created by Steffen Itterheim on 27.11.09.
//  Copyright 2009 Steffen Itterheim. All rights reserved.
//

// this class wraps a Menu with just one item to make creating simple buttons easier

#import "BZSimpleButton.h"
#import "BZMenuItem.h"

//#import "TextureAtlasManager.h"

// menuitem selected images have this filename suffix (change as needed)
//const NSString* kSelectedImageSuffix = @"_aktiv";

@interface BZSimpleButton (Private)
@end

@implementation BZSimpleButton

@synthesize menu;

+(id) simpleButtonAtPosition:(CGPoint)position imageFrame:(NSString*)image target:(id)target selector:(SEL)selector
{
	NSAssert(target != nil, @"SimpleButton - target is nil!");
   
   BZMenuItem *item = [BZMenuItem
      itemFromNormalSpriteFrameName:image
      selectedSpriteFrameName:nil
      target:target
      selector:selector
   ];
   
   //BZSimpleButton *button = [[[self alloc] initWithPosition:position image:image target:target selector:selector] autorelease];
   BZSimpleButton *button = [[[self alloc] initWithPosition:position item:item] autorelease];
	return button;
}

+(id) simpleButtonAtPosition:(CGPoint)position imageFile:(NSString*)image target:(id)target selector:(SEL)selector
{
   
	NSAssert(target != nil, @"SimpleButton - target is nil!");
   BZMenuItem *item = [BZMenuItem
      itemFromNormalSpriteFileName:image
      target:target
      selector:selector
   ];
   
   //BZSimpleButton *button = [[[self alloc] initWithPosition:position image:image target:target selector:selector] autorelease];
   BZSimpleButton *button = [[[self alloc] initWithPosition:position item:item] autorelease];
	return button;
}

//- (id)initWithPosition:(CGPoint)position image:(NSString*)image target:(id)target selector:(SEL)selector
- (id)initWithPosition:(CGPoint)position item:(BZMenuItem *)item
{
	if ((self = [super init]))
	{
		/*
		CCSprite* normalSprite = nil;
		CCSprite* selectedSprite = nil;
		//CCMenuItemSprite* item = nil;
      BZMenuItem* item = nil;

		NSString* normalImage = image; //[NSString stringWithFormat:@"%@.png", image];
		NSString* selectedImage = image; //[NSString stringWithFormat:@"%@%@.png", image, kSelectedImageSuffix];
		
       if ([[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:normalImage] == nil)
		{
			normalSprite = [CCSprite spriteWithFile:normalImage];
			selectedSprite = [CCSprite spriteWithFile:selectedImage];
			item = [CCMenuItemSprite itemFromNormalSprite:normalSprite selectedSprite:selectedSprite target:target selector:selector];
		}
		else
		{
			normalSprite = [[TextureAtlasManager singleton] getSpriteByName:normalImage];
			selectedSprite = [[TextureAtlasManager singleton] getSpriteByName:selectedImage];
			item = [CCMenuItemSprite itemFromNormalSprite:normalSprite selectedSprite:selectedSprite target:target selector:selector];
		}
       */
      
      item_ = item;
      /*
      item_ = [BZMenuItem
         itemFromNormalSpriteFrameName:image
         selectedSpriteFrameName:nil
         target:target
         selector:selector
      ];
       */

      // autopositioning to butt image up against screen edges ...alex
      
      if (kPositionLeftScreenEdge == lrintf(position.x))
         position.x = item_.contentSize.width / 2;
      else if (kPositionRightScreenEdge == lrintf(position.x))
         position.x = [[CCDirector sharedDirector] winSize].width - (item_.contentSize.width / 2);
      
      if (kPositionTopScreenEdge == lrintf(position.y))
         position.y = [[CCDirector sharedDirector] winSize].height - (item_.contentSize.height / 2);
      else if (kPositionBottomScreenEdge == lrintf(position.y))
         position.y = item_.contentSize.height / 2;
      
      // ok, create the menu
      
		int dummyList[2] = {0, 0};
		menu = [[CCMenu alloc] initWithItems:item_ vaList:(va_list)dummyList];      
		menu.position = position;
		[self addChild:menu];
		
		self.tag = kButtonTag;
	}

	return self;
}

-(void) dealloc
{
	[menu release];
	[super dealloc];
}

-(void) setIsEnabled:(bool)enabled
{
	menu.isTouchEnabled = enabled;

	for (CCMenuItem* item in [menu children])
	{
		[item setIsEnabled:enabled];
	}
}

+(void) setIsEnabledForAllButtons:(NSMutableArray*)children enabled:(bool)enabled
{
	for (CCNode* node in children)
	{
		if (node.tag == kButtonTag)
		{
			[((BZSimpleButton*)node) setIsEnabled:enabled];
		}
	}
}

-(void) setColor:(ccColor3B)color
{
	color_ = color;
	menu.color = color;
}

-(ccColor3B) color
{
	return color_;
}

-(GLubyte) opacity
{
	return opacity_;
}

-(void) setOpacity:(GLubyte)opacity
{
	opacity_ = opacity;
	menu.opacity = opacity;
}

- (void)startWaving
{
   [item_ startWaving];
   return;
}

- (void)stopWaving
{
   [item_ stopWaving];
}

@end
