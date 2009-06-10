//
//  TWC2SoundMenuItem.m
//  SapusTongue
//
//  Created by Ricardo Quesada on 17/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//

#import "TWC2SoundMenuItem.h"
#import "SoundEngineManager.h"

//
// A MeneItem that plays a sound each time is is pressed
//
@implementation TWC2SoundMenuItem

-(void) selected {
	[super selected];
	
	[[SoundEngineManager sharedManager] playSound:@"TWC2ButtonTap.caf"];
}
@end
