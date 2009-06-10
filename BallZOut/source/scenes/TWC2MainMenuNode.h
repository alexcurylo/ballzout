//
//  TWC2MainMenuNode.h
//  SapusTongue
//
//  Created by Ricardo Quesada on 06/10/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//

#import "cocos2d.h"
//#import "SoundMenuItem.h"

#ifdef LITE_VERSION
#define AD_REFRESH_PERIOD 60.0f // display fresh ads once per minute
#import "AdMobDelegateProtocol.h"
#endif // LITE_VERSION

#ifdef LITE_VERSION
@interface TWC2MainMenuNode : Layer <AdMobDelegate> {
	AdMobView *adMobAd;   // the actual ad; self.view is the location where the ad will be placed
	BOOL	inStage;
}
-(void) removeAd;
#else
@interface TWC2MainMenuNode : Layer {
}
#endif // LITE_VERSION

+(id) scene;

@end


