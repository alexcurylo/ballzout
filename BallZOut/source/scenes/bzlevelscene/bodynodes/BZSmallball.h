//
//  BZSmallball.h
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import "BZTargetball.h"

@interface BZSmallball : BZTargetball
{
}

// designated initializer
- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game;

@end
