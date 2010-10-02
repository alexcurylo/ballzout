//
//  BZMediumball.h
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import "BZTargetball.h"

@interface BZMediumball : BZTargetball
{
}

// designated initializer
- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game;

@end
