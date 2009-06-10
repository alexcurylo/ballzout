//
//  TWC2CreditsNode.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 12/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//

#import "cocos2d.h"

@interface TWC2CreditsNode : Layer {
	
	NSMutableArray	*nodesToRemove;
	AtlasSprite		*ufo;
	ccTime		time;
	float		ufoY;	
}

+(id) scene;

@end
