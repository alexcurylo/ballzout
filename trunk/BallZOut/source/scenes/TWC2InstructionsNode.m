//
//  TWC2InstructionsNode.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 02/08/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//

//
// The instructions has the "gameplay" code embedded because it was easier to copy & paste it, and then remove
// certain things from it than code a new one from scratch
//
// The entry point of the node is "Init & Creation"
//

#import "TWC2InstructionsNode.h"
#import "TWC2SoundMenuItem.h"
#import "TWC2MainMenuNode.h"
#import "TWC2GradientLayer.h"
/*
 #import <MediaPlayer/MediaPlayer.h>

// cocos2d imports
#import "cocos2d.h"
#import "chipmunk.h"

#define DRAW_SHAPES 0
// local imports
#import "SoundEngineManager.h"
#import "SelectCharNode.h"
#import "TWC2MainMenuNode.h"
#import "SapusTongueAppDelegate.h"

#define kJointX 142
#define kJointY 130

#define kAccelerometerFrequency 60

// random between 0 and 1
#define RANDOM_FLOAT() (((float)random() / (float)0x7fffffff ))

static const float	kSapusTongueLength = 80.0f;
static const float kSapusMass = 1.0f;
static const float kForceFactor = 350.0f;
//static const float kForceFactor = 70.0f;
static const float kSapusElasticity = 0.4f;
static const float kSapusFriction = 0.8f;
static const float kSapusOffsetY = 32;
static const float kWallLength = 16384.0f;

static const float kGravityRoll = -50.0f;
static const float kGravityFly = -175.0f;

static int totalScore = 0;


enum {
	kCollTypeIgnore,
	kCollTypeSapus,
	kCollTypeFloor,
	kCollTypeWalls,
	kCallTypeBee,
};
 */

#pragma mark Chipmunk Callbacks

/*
static void
eachShape(void *ptr, void* instance)
{
//	TWC2InstructionsNode *self = (TWC2InstructionsNode*) instance;
	cpShape *shape = (cpShape*) ptr;
	Sprite *sprite = shape->data;
	if( sprite ) {
		cpVect c;
		cpBody *body = shape->body;
		
		c = cpvadd(body->p, cpvrotate(cpvzero, body->rot));
//		c = body->p;
		
		[sprite setPosition: c];
		[sprite setRotation: CC_RADIANS_TO_DEGREES( -body->a )];
	}
}
*/

#pragma mark TWC2InstructionsNode - Private interaces

@interface TWC2InstructionsNode (Private)
-(void) initBackground;
/*
-(void) initSapus;
-(void) initTongue;
-(void) initJoint;
-(void) initBackground;
-(void) initChipmunk;

-(void) updateDampedSpring: (cpFloat) dt;
-(void) removeJoint;
-(void) updateSapusAngle;
-(void) updateJointLength;
-(void) drawTongue;

-(void) updateRollingVars;
-(void) updateRollingFrames;
-(void) updateFlyingFrames: (ccTime) dt;

-(NSString*) nameForSprite:(NSString*) str;

-(void) throwFinish;
 */
@end

/*
@interface TWC2InstructionsNode (PrivateMovie)
-(NSURL*) movieURL;
-(void)playMovieAtURL:(NSURL*)theURL;
@end
*/

@implementation TWC2InstructionsNode

/*
+(int) score {
	return totalScore;
}
*/

+(Scene*) scene {
	Scene *s = [Scene node];
	
	id game = [TWC2InstructionsNode node];
	[s addChild:game];
	
	return s;
}

#pragma mark TWC2InstructionsNode - Init & Creation

-(id) init
{
	[super init];
	
	isAccelerometerEnabled = YES;

   glEnable(GL_LINE_SMOOTH);
   glEnable(GL_POINT_SMOOTH);
   glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
   glHint(GL_POINT_SMOOTH_HINT, GL_DONT_CARE);
	
	[self initBackground];
	/*
   [self initChipmunk];
	[self initTongue];
	*/
   
	Menu *menu;
	/*
    MenuItem* item1 = [TWC2SoundMenuItem itemFromNormalImage:@"btn-viewvideo-normal.png" selectedImage:@"btn-viewvideo-selected.png" target:self selector:@selector(viewvideoCB:)];	
	MenuItem* item2 = [TWC2SoundMenuItem itemFromNormalImage:@"btn-menumed-normal.png" selectedImage:@"btn-menumed-selected.png" target:self selector:@selector(menuCB:)];	

	menu = [Menu menuWithItems:item1, item2, nil];
    */
	MenuItem* item1 = [TWC2SoundMenuItem itemFromNormalImage:@"btn-menumed-normal.png" selectedImage:@"btn-menumed-selected.png" target:self selector:@selector(menuCB:)];	
   
	menu = [Menu menuWithItems:item1, nil];
   
	[menu alignItemsVertically];
	menu.position = cpv(420,45);
	[self addChild:menu z:1];
		
	
	[self schedule: @selector(delayStart:) interval:1.0f];
   /*
	[self schedule: @selector(step:)];
	
 totalScore = 0;
	
	_accelValsRecieved = NO;
	_accelDelay = 0;
*/
   
	return self;
}

-(void) initBackground {

	// tree
	
	// back color
	TWC2GradientLayer *g = [TWC2GradientLayer layerWithColor:0];
	[g setBottomColor:0xc3f2f6ff topColor:0x73a2a6ff];
	[g changeHeight:320];
	[g changeWidth:480];
	[self addChild: g z:-10];	
	
	Sprite *tree = [Sprite spriteWithFile:@"TWC2InstructionsBackground.png"];
	tree.transformAnchor = cpvzero;
	[self addChild:tree z:-1];
}


/*
-(void) initChipmunk {
	
	cpInitChipmunk();
		
	cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
	space = cpSpaceNew();
	cpSpaceResizeStaticHash(space, kWallLength, 30);
	cpSpaceResizeActiveHash(space, 100, 100);

	space->elasticIterations = space->iterations = 10;
	space->gravity = cpv(0, kGravityRoll);
	
	cpShape *shape;

	// pivot point. fly
	Sprite *fly = [Sprite spriteWithFile:@"fly.png"];
	[self addChild:fly z:1];
	
	pivotBody = cpBodyNew(INFINITY, INFINITY);
	pivotBody->p =  cpv(kJointX,kJointY);
	shape = cpCircleShapeNew(pivotBody, 5.0f, cpvzero);
	shape->e = 0.9f;
	shape->u = 0.9f;
	shape->data = fly;
	cpSpaceAddStaticShape(space, shape);

	
	GLfloat wallWidth = 1;

	// floor
	shape = cpSegmentShapeNew(staticBody, cpv(-wallWidth,-wallWidth+1), cpv(kWallLength,-wallWidth), wallWidth+1);
	shape->e = 0.5f;
	shape->u = 0.9f;
	shape->collision_type = kCollTypeFloor;
	cpSpaceAddStaticShape(space, shape);
		
	// left
	shape = cpSegmentShapeNew(staticBody, cpv(-wallWidth,-wallWidth), cpv(-wallWidth,2000), wallWidth);
	shape->e = 0.2f;
	shape->u = 1.0f;
	cpSpaceAddStaticShape(space, shape);
	
	// right
	shape = cpSegmentShapeNew(staticBody, cpv(kWallLength,-wallWidth), cpv(kWallLength,2000), wallWidth);
	shape->e = 0.0f;
	shape->u = 1.5f;
	cpSpaceAddStaticShape(space, shape);
	
	
//	LevelMgr *lvlmgr = [[LevelMgr alloc] init];
//	[lvlmgr loadLevel:0 space:space];
		
	[self initSapus];
	[self initJoint];
	[self addJoint];
}
*/

/*
-(void) initJoint {
//	joint = cpPinJointNew(sapusBody, pivotBody, cpvzero, cpvzero);
//	joint = cpGrooveJointNew(sapusBody, pivotBody, cpv(0, 40), cpv(0,100), cpv(0, 0));

	joint = cpPivotJointNew(sapusBody, pivotBody, cpv(kJointX, kJointY));
//	joint = cpSlideJointNew(sapusBody, pivotBody, cpvzero, cpvzero, 0, kSapusTongueLength);

}
*/


/*
-(void) initSapus
{
	int sapusY = 0;
	AtlasSpriteManager *spriteManager = nil;
	if( [SelectCharNode selectedChar] == 0 ) {
		spriteManager = [[AtlasSpriteManager spriteManagerWithFile:@"sprite-sheet-sapus.png"] retain];
		sapusSprite = [[AtlasSprite spriteWithRect:CGRectMake(64*2, 64*0, 64, 64) spriteManager:spriteManager] retain];
		sapusY = 0;
	} else {
		spriteManager = [[AtlasSpriteManager spriteManagerWithFile:@"sprite-sheet-monus.png"] retain];
		sapusSprite = [[AtlasSprite spriteWithRect:CGRectMake(64*2, 64*0, 64, 64) spriteManager:spriteManager] retain];
		sapusY = 2;
	}
	
	[spriteManager addChild:sapusSprite];
	
	
	cpVect ta = sapusSprite.transformAnchor;
	ta.y = kSapusOffsetY;
	sapusSprite.transformAnchor = ta;
	
	// Roll Frame
	AtlasAnimation *animRoll = [AtlasAnimation animationWithName:@"roll" delay:0.2f];
	[animRoll addFrameWithRect:CGRectMake(64*2, 64*sapusY, 64, 64)];	
	[sapusSprite addAnimation:animRoll];
	
	AtlasAnimation *animFly = [AtlasAnimation animationWithName:@"fly" delay:0.2f];
	[animFly addFrameWithRect: CGRectMake(64*0, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*1, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*2, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*3, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*0, 64*1, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*3, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*2, 64*0, 64, 64)];
	[animFly addFrameWithRect: CGRectMake(64*1, 64*0, 64, 64)];
	[sapusSprite addAnimation:animFly];
	
	// monus
	if( [SelectCharNode selectedChar] == 1 ) {
		AtlasAnimation *animNoTail = [AtlasAnimation animationWithName:@"notail" delay:0.2f];
		[animNoTail addFrameWithRect: CGRectMake(64*0, 64*2, 64, 64)];
		[animNoTail addFrameWithRect: CGRectMake(64*1, 64*2, 64, 64)];
		[animNoTail addFrameWithRect: CGRectMake(64*2, 64*2, 64, 64)];
		[animNoTail addFrameWithRect: CGRectMake(64*3, 64*2, 64, 64)];
		[animNoTail addFrameWithRect: CGRectMake(64*0, 64*3, 64, 64)];
		[animNoTail addFrameWithRect: CGRectMake(64*3, 64*2, 64, 64)];
		[animNoTail addFrameWithRect: CGRectMake(64*2, 64*2, 64, 64)];
		[animNoTail addFrameWithRect: CGRectMake(64*1, 64*2, 64, 64)];
		[sapusSprite addAnimation:animNoTail];		
	}
	
	
	[self addChild:spriteManager z:-1];
	
	
#if 0
	int	numVertices = 3;
	cpVect verts[] = {
		cpv( 0		, 64 - kSapusOffsetY ),
		cpv( -32 	, 0 - kSapusOffsetY ),
		cpv( 32 	, 0 - kSapusOffsetY ),
	};
#else
	//	int	numVertices = 6;
	//	cpVect verts[] = {
	//		cpv(  9		, 58 - kSapusOffsetY ),
	//		cpv( -9		, 58 - kSapusOffsetY ),
	//		cpv( -22 	, 20 - kSapusOffsetY ),
	//		cpv( -17 	, 0 - kSapusOffsetY ),
	//		cpv( 17 	, 0 - kSapusOffsetY ),
	//		cpv( 22 	, 20 - kSapusOffsetY ),
	//	};	
#endif
	
	//	cpFloat moment = cpMomentForPoly(kSapusMass, numVertices, verts, cpvzero);
	
	cpFloat radius = 12;
	
	cpFloat moment = cpMomentForCircle(kSapusMass/5.0f, 0, radius, cpv(0,(64-radius)-kSapusOffsetY) );
	moment += cpMomentForCircle(kSapusMass/5.0f, 0, radius, cpv(-14,3+radius-kSapusOffsetY) );
	moment += cpMomentForCircle(kSapusMass/5.0f, 0, radius, cpv(14,3+radius-kSapusOffsetY) );
	moment += cpMomentForCircle(kSapusMass/5.0f, 0, radius, cpv(22,29+radius-kSapusOffsetY) );
	moment += cpMomentForCircle(kSapusMass/5.0f, 0, radius, cpv(-22,29+radius-kSapusOffsetY) );
	
	sapusBody = cpBodyNew(kSapusMass, moment);
	
	sapusBody->p = pivotBody->p;
	sapusBody->p.y = pivotBody->p.y - kSapusTongueLength;
	//	sapusBody->p.y = 30;
	
	cpSpaceAddBody(space, sapusBody);
	
	
	//
	// The Sapus / Monus is simulated with 5 circles
	//
	//	cpShape *shape = cpPolyShapeNew(sapusBody, numVertices, verts, cpvzero);
	cpShape *shape = cpCircleShapeNew(sapusBody, radius, cpv(0,(64-radius)-kSapusOffsetY) );
	shape->e = kSapusElasticity;
	shape->u = kSapusFriction;
	shape->collision_type = kCollTypeSapus;	
	shape->data = sapusSprite;
	cpSpaceAddShape(space, shape);
	
	shape = cpCircleShapeNew(sapusBody, radius, cpv(-14,3+radius-kSapusOffsetY) );
	shape->e = kSapusElasticity;
	shape->u = kSapusFriction;
	shape->collision_type = kCollTypeSapus;	
	cpSpaceAddShape(space, shape);
	
	shape = cpCircleShapeNew(sapusBody, radius, cpv(14,3+radius-kSapusOffsetY) );
	shape->e = kSapusElasticity;
	shape->u = kSapusFriction;
	shape->collision_type = kCollTypeSapus;	
	cpSpaceAddShape(space, shape);
	
	shape = cpCircleShapeNew(sapusBody, radius, cpv(22,29+radius-kSapusOffsetY) );
	shape->e = kSapusElasticity;
	shape->u = kSapusFriction;
	shape->collision_type = kCollTypeSapus;	
	cpSpaceAddShape(space, shape);
	
	shape = cpCircleShapeNew(sapusBody, radius, cpv(-22,29+radius-kSapusOffsetY) );
	shape->e = kSapusElasticity;
	shape->u = kSapusFriction;
	shape->collision_type = kCollTypeSapus;	
	cpSpaceAddShape(space, shape);	
}
*/


/*
-(void) initTongue {
	if( [SelectCharNode selectedChar] == 0 )
		tongue = [[TextureMgr sharedTextureMgr] addImage: @"SapusTongue.png"];
	else
		tongue = [[TextureMgr sharedTextureMgr] addImage: @"MonusTail.png"];
	[tongue retain];
}
*/

- (void)dealloc
{
/*
 [sapusSprite release];
	[tongue release];
	
	cpSpaceFreeChildren(space);
	cpSpaceFree(space);
 */
	[super dealloc];
}

//
// The heavy part of init and the UIKit controls are initialized after the transition is finished.
// This trick is used to:
//    * create a smooth transition (load heavy resources after the transition is finished)
//    * show UIKit controls after the transition to simulate that they transition like any other control
//
-(void) delayStart: (ccTime) dt
{
   (void)dt;
   
	[self unschedule:_cmd];

	/*
    state = kGameStart;
	*/
   
	// to prevent artifacts while rendering tiles
//	[[Director sharedDirector] set2Dprojection];
//	[[Director sharedDirector] setDepthTest: NO];
}

-(void) onEnter
{
	[super onEnter];
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];

}

#pragma mark TWC2InstructionsNode - Main Loop


/*
-(void) step: (ccTime) delta
{
	cpBodyResetForces(sapusBody);

//	cpVect impulse = cpvmult(force, 10);
	cpVect f = cpvmult(force, kForceFactor);

	if( state == kGameStart ) {
		
//		cpBodyApplyImpulse(sapusBody, impulse, cpvzero);
		cpBodyApplyForce(sapusBody, f, cpvzero);
//		[self updateDampedSpring: delta];
//		[self updateSapusAngle];
//		[self updateJointLength];
		
		[self updateRollingFrames];
		
		[self updateRollingVars];

	} else if( state == kGameFlying ) {
		totalScore = sapusBody->p.x;

		sapusBody->t = -(sapusBody->w) * sapusBody->i / 4.0f;
		
		[self updateFlyingFrames: delta];
		if( cpvlength(sapusBody->v) <= 1.0 && sapusBody->p.y <= 70 ) {
			[self throwFinish];
		}
	}

	int steps = 7;
	cpFloat dt = delta/(cpFloat)steps;
	
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
	
	// update screen position
	if( sapusBody->p.x > 260 )
		position.x = -(sapusBody->p.x - 260);
	else
		position.x = 0;
	if( sapusBody->p.y > 244 )
		position.y = -(sapusBody->p.y - 244);
	else
		position.y = 0;
	
	if(_accelValsRecieved == NO) {
		_accelDelay++;
		if(_accelDelay == 25) {
			_accelDelay = 0;
			[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
			[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
			[[UIAccelerometer sharedAccelerometer] setDelegate:self];
		}
	}	
}
*/


/*
-(void) updateDampedSpring: (cpFloat) dt {
	cpDampedSpring(sapusBody, pivotBody, cpvzero, cpvzero, 75, 200.0f, 50.0f, dt);
}
*/

/*
-(void) updateSapusAngle {
	cpVect diff = cpvsub(pivotBody->p,sapusBody->p);
	cpFloat a = cpvtoangle(diff);
	sapusBody->a = a - (float)M_PI_2;
}
*/

/*
-(void) updateJointLength {
	cpSlideJoint *j = (cpSlideJoint*) joint;	
	cpFloat v = cpvlength( sapusBody->v );
	
	j->max = kSapusTongueLength + (v / 13.0f);
	j->max = MAX(j->max, kSapusTongueLength);
	j->max = MIN(j->max, kSapusTongueLength+70);
}
*/

/*
-(void) updateRollingVars {
	
	// velocity
	throwVelocity = cpvlength( sapusBody->v );

	// angle
	cpVect diff = cpvsub(pivotBody->p,sapusBody->p);
	cpFloat a = cpvtoangle(diff);
	throwAngle = CC_RADIANS_TO_DEGREES(a);
}
*/

/*
-(void) updateRollingFrames {
	[sapusSprite setDisplayFrame:@"roll" index:0];
}
*/

/*
-(void) updateFlyingFrames: (ccTime) dt {
	
	if( cpvlength(sapusBody->v) > 100 ) {
		flyingDeltaAccum += dt;

		int idx = flyingDeltaAccum  / 0.06f;
		[sapusSprite setDisplayFrame:@"fly" index: idx%8];
	}
}
*/

/*
-(void) draw
{
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	cpSpaceHashEach(space->activeShapes, &eachShape, self);
	cpSpaceHashEach(space->staticShapes, &eachShape, self);
	
//	drawPointDeprecated( kJointX,kJointY);
	
	if( state == kGameStart || state == kGameDrawTongue )
		[self drawTongue];
}
*/

/*
-(void) drawTongue {
	
	GLfloat	 coordinates[] = {  0,				tongue.maxT,
								tongue.maxS,	tongue.maxT,
								0,				0,
								tongue.maxS,	0  };
	

	cpVect sapusV = sapusBody->p;
	float angle = cpvtoangle( cpvsub(pivotBody->p, sapusV) );
	float x = sinf(angle);
	float y = -cosf(angle);

	float ys = sinf( sapusBody->a + (float)M_PI_2);
	float xs = cosf( sapusBody->a + (float)M_PI_2);

	float tongueLen = 11;
	if( [SelectCharNode selectedChar] == 0 )
		tongueLen = 15;
	
	sapusV.x = sapusV.x + tongueLen*xs;
	sapusV.y = sapusV.y + tongueLen*ys;	
	
	GLfloat	vertices[] = {	sapusV.x - x*1.5f,		sapusV.y - y*1.5f,		0.0f,
							sapusV.x + x*1.5f,		sapusV.y + y*1.5f,		0.0f,
							pivotBody->p.x - x*1.5f,	pivotBody->p.y - y*1.5f,	0.0f,
							pivotBody->p.x + x*1.5f,	pivotBody->p.y + y*1.5f,	0.0f };
	
	glEnableClientState( GL_VERTEX_ARRAY);
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );
	
	glEnable( GL_TEXTURE_2D);
	
	
	glBindTexture(GL_TEXTURE_2D, tongue.name );
	glVertexPointer(3, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	glDisable( GL_TEXTURE_2D);	
	glDisableClientState(GL_VERTEX_ARRAY );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );


//	glColor4ub(224,32,32,255);
//	drawLineDeprecated(sapusBody->p.x + 16*xs,
//			 sapusBody->p.y + 16*ys,
//			 pivotBody->p.x,
//			 pivotBody->p.y);
//	glColor4ub(255,255,255,255);
}
*/

/*
-(void) addJoint {
	cpSpaceAddJoint(space, joint);
	jointAdded = YES;
	state = kGameStart;
	totalScore = 0;
	space->gravity = cpv(0, kGravityRoll);
//	space->gravity = cpv(0, 0);

}
*/

/*
-(void) removeJoint {
	cpSpaceRemoveJoint(space, joint);
	jointAdded = NO;
	state = kGameFlying;
	space->gravity = cpv(0, kGravityFly);

	
	if( cpvlength(sapusBody->v) > 630 ) {
		int r = RANDOM_FLOAT() * 6;
		switch (r) {
			case 0:
				[[SoundEngineManager sharedManager] playSound:@"snd-gameplay-mama.caf"];
				break;
			case 1:
				[[SoundEngineManager sharedManager] playSound:@"snd-gameplay-geronimo.caf"];
				break;
			case 2:
				[[SoundEngineManager sharedManager] playSound:@"snd-gameplay-yaaa.caf"];
				break;
			case 3:
				[[SoundEngineManager sharedManager] playSound:@"snd-gameplay-argh.caf"];
				break;
			case 4:
				[[SoundEngineManager sharedManager] playSound:@"snd-gameplay-yupi.caf"];
				break;
			case 5:
				[[SoundEngineManager sharedManager] playSound:@"snd-gameplay-waka.caf"];
				break;				
				
		}
	}
}
*/

/*
-(void) throwFinish {
	state = kGameOver;
}
*/

/*
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	static float prevX=0, prevY=0;
	
	_accelValsRecieved = YES;

#define kFilterFactor 0.05f
	
	if( state == kGameStart ) {
		float accelX = (float)acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
		float accelY = (float)acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
		prevX = accelX;
		prevY = accelY;
		
		// landscape mode
		force = cpv( (float)-acceleration.y, (float)acceleration.x);			
	} else if( state == kGameFlying ) {
		force = cpvzero;
	}
}
*/

/*
-(NSString*) nameForSprite:(NSString*) str {
	NSString *s;
	s = [NSString stringWithFormat:str, "sapus"];
	return s;
}
*/

#pragma mark Menu Callbacks
-(void) menuCB:(id) sender
{
   (void)sender;

	[[Director sharedDirector] replaceScene: [ShrinkGrowTransition transitionWithDuration:1.0f scene: [TWC2MainMenuNode scene]]];
}

/*
 -(void) viewvideoCB:(id) sender
{
	// Web page
//	CGRect frame = [[UIScreen mainScreen] applicationFrame];	
//	WebPage *webPage = [[WebPage alloc] initWithFrame:frame];
//	
//	[webPage setTitle:@"Instructions"];
//	[webPage loadURL:@"http://www.youtube.com/watch?v=GNYbYcIqlxM"];
//	[[[Director sharedDirector] window] addSubview:webPage];
//	
//	[WebPage release];
	
	[self playMovieAtURL:[self movieURL]];
}
*/

/*
 // return a URL for the movie file in our bundle
-(NSURL *)movieURL
{
    if (mMovieURL == nil)
    {
        NSBundle *bundle = [NSBundle mainBundle];
        if (bundle) 
        {
            NSString *moviePath = [bundle pathForResource:@"Movie" ofType:@"m4v"];
            if (moviePath)
            {
                mMovieURL = [NSURL fileURLWithPath:moviePath];
                [mMovieURL retain];
            }
        }
    }
    
    return mMovieURL;
}
*/


/*
-(void)playMovieAtURL:(NSURL*)theURL
{
    MPMoviePlayerController* theMovie = [[MPMoviePlayerController alloc] initWithContentURL:theURL];
	
    theMovie.scalingMode = MPMovieScalingModeAspectFit;
	theMovie.movieControlMode = MPMovieControlModeDefault;
//    theMovie.movieControlMode = MPMovieControlModeVolumeOnly;
	
    // Register for the playback finished notification.
    [[NSNotificationCenter defaultCenter] addObserver:self
											selector:@selector(myMovieFinishedCallback:)
											name:MPMoviePlayerPlaybackDidFinishNotification
											object:theMovie];

	// MPMoviePlayerController *player
//	[[NSNotificationCenter defaultCenter]
//									addObserver:self
//									selector:@selector(handlePreload:)
//									name:MPMoviePlayerContentPreloadDidFinishNotification
//									object:theMovie
//	];
	
	//
	[[SoundEngineManager sharedManager] shutdown];

    // Movie playback is asynchronous, so this method returns immediately.
    [theMovie play];
}
*/

//-(void)handlePreload:(NSNotification *)aNotification {
//	NSDictionary *userInfo = [aNotification userInfo];
//	NSError *error = [userInfo objectForKey:@"error"];
//	MPMoviePlayerController *player = [aNotification object];
//	twlog(@"VIDEO URL : %@",player.contentURL);
//    
//	if(error != nil) {
//		twlog(@"Error loading video : %@",error);
//		// Cleanup
//	} else {
//		[player play];
//	}
//}


/*
 // When the movie is done, release the controller.
-(void)myMovieFinishedCallback:(NSNotification*)aNotification
{
    MPMoviePlayerController* theMovie = [aNotification object];
	
    [[NSNotificationCenter defaultCenter] removeObserver:self
											name:MPMoviePlayerPlaybackDidFinishNotification
											object:theMovie];
	
    // Release the movie instance created in playMovieAtURL:
    [theMovie release];

	// allocate everything again (after a shutdown)
	[[SoundEngineManager sharedManager] init];
	
	SapusTongueAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[appDelegate preLoadSounds];	
	[[SoundEngineManager sharedManager] playTrack:@"TWC2BackgroundMusic.mp3"];
}
*/

@end

