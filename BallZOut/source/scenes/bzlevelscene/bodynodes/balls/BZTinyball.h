//
//  BZTinyball.h
//
//  Copyright 2010 Sapus Media. All rights reserved.
//


#import "BZTargetball.h"

@interface BZTinyball : BZTargetball
{
}

// designated initializer
//- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game;
- (id)initWithBody:(b2Body*)body params:(NSDictionary *)params scene:(BZLevelScene *)game;

@end
