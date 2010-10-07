//
//  BZHeroball.h
//
//  Copyright 2010 Sapus Media. All rights reserved.
//

#import "BZBall.h"

@interface BZHeroball : BZBall
{
   BOOL isHero_;
}

@property (readwrite, nonatomic) BOOL isHero;

// when placed in scene file
//- (id)initWithBody:(b2Body*)body gameScene:(BZLevelScene*)game;
- (id)initWithBody:(b2Body*)body params:(NSDictionary *)params scene:(BZLevelScene *)game;

// when created by game
- (id)initWithPosition:(b2Vec2)position gameScene:(BZLevelScene*)game;

// called when move beyond bounds in -update
- (void)outsideBounds;

@end
