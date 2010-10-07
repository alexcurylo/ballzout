//
//  BZBall.h
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import "BZBodyNode.h"

@interface BZBall : BZBodyNode
{
	BOOL removeMe_;
   //NSString *framePrefix_;
}

// designated initializer
- (id)initWithBody:(b2Body*)body
params:(NSDictionary *)params
         gameScene:(BZLevelScene*)game
          diameter:(CGFloat)diameter
       spriteFrame:(NSString *)spriteFrame;

// called when move beyond bounds in -update
- (void)outsideBounds;

// see if we need to move back
- (void)update:(ccTime)dt;

@end
