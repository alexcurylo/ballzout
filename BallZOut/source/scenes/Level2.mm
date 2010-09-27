//
//  Level2.mm
//  LevelSVG
//
//  Created by Ricardo Quesada on 06/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//
//  DO NOT DISTRIBUTE THIS FILE WITHOUT PRIOR AUTHORIZATION


//
// Level2:
//
// Details:
//
// It uses 2 batch nodes:
//
//  * 1 batch node for the sprites
//  * 1 batch node for the platorms
//
// Why ?
// Becuase the platforms uses a different a different texture parameter
// When you using batch nodes, all the sprites MUST share the same texture and the same texture parameters
//
// TIP:
// The platforms used in this level uses the GL_REPEAT texture parameter.
// If you open the platforms.png file, you will notice the both images are 128x128. This is on purpose. You can't add more images horizontally.
// But you can add more images vertically... (only if the platforms are not higher than 128 pixels).
//
// It also uses a Parallax with 3 children:
//  - background image
//  - platforms
//  - sprites (hero, fruits, princess, etc)
//
//
// How to create a similar level ?
//	1. Open Inkscape and create a new document of 480x320. Actually it can be of any size, but it is useful as a reference.
//		-> Inkscape -> File -> Document Properties -> Custom size: width=480, height=320
//	2. Create 1 layer:
//		-> physics:objects
//	3. Start designing the world.
//
// IMPORTANT: gravity and controls are read from the svg file
//

#import "Level2.h"
#import "BodyNode.h"
#import "Box2dDebugDrawNode.h"


@implementation Level2
-(void) initGraphics
{	
	// sprites
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist"];
	// platforms
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"platforms.plist"];

	//
	// TIP
	// Use 16-bit texture in background. It consumes half the memory
	//
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
	//CCSprite *background = [CCSprite spriteWithFile:@"background3.png"];
	CCSprite *background = [CCSprite spriteWithFile:@"arena1.jpg"];
	background.anchorPoint = ccp(0,0);
   //background.position = ccp(size.width/2, size.height/2);

	// Restore 32-bit texture format
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
	
	// weak ref
	spritesBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png" capacity:20];
	
	// weak ref
	platformBatchNode_ = [CCSpriteBatchNode batchNodeWithFile:@"platforms.png" capacity:10];
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[platformBatchNode_.texture setTexParameters:&params];
	
	//
	// Parallax Layers
	//
   /*
	CCParallaxNode *parallax = [CCParallaxNode node];
	
	// background is parallaxed
	[parallax addChild:background z:-10 parallaxRatio:ccp(0.08f, 0.08f) positionOffset:ccp(-30,-30)];
	
	// TIP: Disable this node in release mode
	// Box2dDebug draw in front of background
   Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];
   [parallax addChild:b2node z:0 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];

	// batchnodes: platforms should be drawn before sprites
	[parallax addChild:platformBatchNode_ z:5 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	[parallax addChild:spritesBatchNode_ z:10 parallaxRatio:ccp(1,1) positionOffset:ccp(0,0)];
	
	[self addChild:parallax];
    */

   [self addChild:background z:-10];

   // TIP: Disable this node in release mode
	// Box2dDebug draw in front of background
	Box2dDebugDrawNode *b2node = [Box2dDebugDrawNode nodeWithWorld:world_];
	[self addChild:b2node z:0];
   
   // batchnodes: platforms should be drawn before sprites
	[self addChild:platformBatchNode_ z:5];
	[self addChild:spritesBatchNode_ z:10];
   
   [self setContentSize:[background contentSize]];
}

- (void) dealloc
{
	[super dealloc];
}

-(CGRect) contentRect
{
	// These values were obtained from Inkscape -- the size of the "dimensions" object
	//return CGRectMake(-313, -120, 1240, 464);
	return CGRectMake(0, 0, 320, 480);
}

-(NSString*) SVGFileName
{
	return @"level2.svg";
}

// This is the default behavior
-(void) addBodyNode:(BodyNode*)node z:(int)zOrder
{
	switch (node.preferredParent) {
		case BN_PREFERRED_PARENT_SPRITES_PNG:
		
			// Add to sprites' batch node
			[spritesBatchNode_ addChild:node z:zOrder];
			break;

		case BN_PREFERRED_PARENT_PLATFORMS_PNG:
			// Add to platform batch node
			[platformBatchNode_ addChild:node z:zOrder];
			break;
		default:
			CCLOG(@"Level2: Unknonw preferred parent");
			break;
	}
}

@end
