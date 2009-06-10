//
//  TWC2CreditsNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 12/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//

//
// A nice credits scene that shows a "scrolling" layer and some sprites moving from here to there
//
#import "TWC2CreditsNode.h"
#import "TWC2SoundMenuItem.h"
#import "TWC2GradientLayer.h"
#import "TWC2MainMenuNode.h"

/*
 enum {
	kTagSpriteManagerUFO =1,
	kTagSpriteManagerSapus =1,
};
*/

@interface TWC2CreditsNode (Private)
-(void) initGradient;
-(void) initButton;
/*
 -(void) initufo;
-(void) initTree;
-(void) initTreeMask;
*/
@end

@implementation TWC2CreditsNode

+(id) scene {
	Scene *s = [Scene node];
	id node = [TWC2CreditsNode node];
	[s addChild:node];
	return s;
}

-(id) init {
	if( ! (self = [super init]) )
		return nil;
	
	nodesToRemove = [[NSMutableArray arrayWithCapacity:2] retain];

	[self initGradient];
/*
 [self initufo];
	[self initTree];
	[self initTreeMask];
*/
	[self initButton];

	[self schedule:@selector(delayMeteor:) interval:20];
	[self schedule:@selector(delayJump:) interval:8];
	[self schedule:@selector(initCredits:) interval:1.5f];
	return self;
}

-(void) dealloc {
	[nodesToRemove release];
	[ufo release];
	[super dealloc];
}

-(void) initButton {
	MenuItemImage *item1 = [TWC2SoundMenuItem itemFromNormalImage:@"btn-menumed-normal.png" selectedImage:@"btn-menumed-selected.png" target:self selector:@selector(menuCallback:)];
	Menu *menu = [Menu menuWithItems:item1, nil];
	[self addChild:menu z:10];
	menu.position = ccp(425,295);
}

-(void) initGradient {
	// back color
	TWC2GradientLayer *g = [TWC2GradientLayer layerWithColor:0];
	[g setBottomColor:0xb3e2e6ff topColor:0x000000ff];
	[g changeHeight:320];
	[g changeWidth:480];
	[self addChild: g z:-10];	
}

/*
 -(void) initufo {
	// ufo
	AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:@"sprite-sheet-ufo.png"];
	[self addChild:mgr z:-8 tag:kTagSpriteManagerUFO];

	ufo = [[AtlasSprite spriteWithRect:CGRectMake(0,0,138,84) spriteManager:mgr] retain];
	
	AtlasAnimation *ufos = [AtlasAnimation animationWithName:@"ufos" delay:0.0f];
	[ufos addFrameWithRect:CGRectMake(0,0,138,84)]; // UFO 1
	[ufos addFrameWithRect:CGRectMake(0,168,195,87)]; // UFO 2
	[ufos addFrameWithRect:CGRectMake(176,0,81,160)]; // UFO 3
	
	[ufo addAnimation:ufos];
	
	ufo.visible = NO;
	ufo.scale = 0.4f;
	ufo.position = ccp(540,260);
	[mgr addChild:ufo];
	
	// ufo trigger
	[self schedule:@selector(triggerUFO:) interval:10];
	[self schedule:@selector(step:)];
}
*/
-(void) initTree {
	Sprite *tree = [Sprite spriteWithFile:@"SapusCreditsBackground.png"];
	[self addChild:tree z:-5];
	tree.transformAnchor = CGPointZero;
}

-(void) initTreeMask {
}

-(void) initCredits: (ccTime) dt
{
   (void)dt;
   
	[self unschedule:_cmd];

	Sprite *credits = [Sprite spriteWithFile:@"TWC2CreditsScrolling.png"];
	credits.transformAnchor = CGPointZero;
	[self addChild:credits z:5];
	
	credits.position = ccp(0,-680);
	id action = [Sequence actions:
					[MoveBy actionWithDuration:40.0f position:ccp(0,1200)],
					[Place actionWithPosition: ccp(0,-700)],
				 nil];
	
	[credits runAction: [RepeatForever actionWithAction:action]];
	
	/*
    AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:@"sprite-sheet-sapus.png"];
	[credits addChild:mgr z:1 tag:kTagSpriteManagerSapus];

	// animated sapus
	AtlasSprite *sapus = [AtlasSprite spriteWithRect:CGRectMake(64*2, 0, 64, 64) spriteManager:mgr];
	AtlasAnimation *animFly = [AtlasAnimation animationWithName:@"fly" delay:0.14f];
	[animFly addFrameWithRect: CGRectMake(64*0, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*1, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*2, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*3, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*0, 64*1, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*3, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*2, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*1, 64*0, 64, 64)];
	[sapus addAnimation:animFly];
	
	[mgr addChild:sapus];
	sapus.position = ccp(240,50+12);
	
	id animate = [Animate actionWithAnimation: animFly];
	[sapus runAction: [RepeatForever actionWithAction:animate]];
   */
}

-(void) delayJump:(ccTime) dt
{
   (void)dt;

	[self unschedule:_cmd];
	
	/*
   AtlasSpriteManager *mgr = [AtlasSpriteManager spriteManagerWithFile:@"sprite-sheet-sapus.png"];
	AtlasSprite *sprite = [AtlasSprite spriteWithRect:CGRectMake(64*0, 64*1, 64, 64) spriteManager:mgr];
	[mgr addChild:sprite];
	[self addChild: mgr z:-2];
	sprite.position = ccp(30,20);
	
	IntervalAction* jumpBy = [JumpBy actionWithDuration:6 position:ccp(435,0) height:50 jumps:4];
	IntervalAction* rotateBy = [RotateBy actionWithDuration:6 angle:180*4];
	IntervalAction* jumpRot = [Spawn actions: jumpBy, rotateBy, nil];
	IntervalAction* invJumpRot = [jumpRot reverse];
	id seq = [Sequence actions: jumpRot, invJumpRot, nil];
	id repeat = [RepeatForever actionWithAction: seq];
	
	[sprite runAction: repeat];
    */
}


-(void) delayMeteor: (ccTime) dt
{
   (void)dt;

	ParticleMeteor *meteor = [[ParticleMeteor alloc] initWithTotalParticles:150];
	// custom meteor
	meteor.size = 30.0f;
	meteor.gravity = ccp(-80,15);
	meteor.life = 1.0f;
	meteor.speed = 8;
	meteor.position = ccp( -80, 320);

	[self addChild:meteor z:-10];
	[meteor release];
	
	IntervalAction *action = [Sequence actions:
								[MoveBy actionWithDuration: 4.0f position: ccp(700,-131)],
								[CallFuncN actionWithTarget:self selector:@selector(removeNodeCallback:)],
								nil];
	[meteor runAction:action];
}

-(void) step:(ccTime) dt {
	
	for(id node in nodesToRemove) {
		[self removeChild:node cleanup:YES];
	}
	[nodesToRemove removeAllObjects];

	time += dt;
	CGPoint v = ufo.position;
	
	float diffx = (dt *480.0f) / 8.0f;
	v.x -= diffx;
	
	v.y = ufoY + sinf(v.x / 40.0f) * 40.0f;
	
	ufo.position = v;
}

-(void) triggerUFO:(ccTime) dt
{
   (void)dt;

	float x = 500 + CCRANDOM_0_1() * 80;
	ufoY = 100 + CCRANDOM_0_1() * 220;
	ufo.position = ccp(x,ufoY);
	ufo.visible = ~ufo.visible;
	ufo.scale = 0.2f + CCRANDOM_0_1()/2.0f;
	
	[ufo setDisplayFrame:@"ufos" index:CCRANDOM_0_1()*3.0f];
}

#pragma mark TWC2CreditsNode - callbacks

-(void) removeNodeCallback:(id) node {
	[nodesToRemove addObject:node];
}

-(void) menuCallback:(id) sender
{
   (void)sender;

	ufo.visible = NO;
    [[Director sharedDirector] replaceScene: [TurnOffTilesTransition transitionWithDuration:1.0f scene:[TWC2MainMenuNode scene] ]];

}
@end
