//
//  BZLargeball.h
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import "BZBall.h"

@interface BZTargetball : BZBall
{
}

// designated initializer
- (id)initWithBody:(b2Body*)body
params:(NSDictionary *)params
         gameScene:(BZLevelScene*)game
          diameter:(CGFloat)diameter
       spriteFrame:(NSString *)spriteFrame;

// called when move beyond bounds in -update
- (void)outsideBounds;

@end
