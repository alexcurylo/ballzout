//
//  SoundEngineManager.h
//
//  Created by Hoan Ton-That on 7/21/08.
//	Modified by Ricardo Quesada
//

#import <UIKit/UIKit.h>

#import "SoundEngine.h"

@interface SoundEngineManager : NSObject {
	NSBundle *bundle;
	NSString *currentTrack;
	BOOL playing;

	NSMutableDictionary *sounds;
	BOOL muted;
}

@property (nonatomic, retain) NSString *currentTrack;
@property (readwrite, assign) BOOL muted;

+ (SoundEngineManager*) sharedManager;
+ (void) setFrequency: (float) freq;

-(id) initWithFrequency: (float) freq;

// main
// deallocates allocated resources
-(void) shutdown;

// background API
- (void) playTrack:(NSString*)soundfile;
- (void) stop;
- (void) pause;
- (void) resume;

// sound effects API
- (NSNumber*) addSound: (NSString*) soundfile;
- (void) removeSound: (NSString*) soundfile;
- (void) playSound: (NSString*) soundfile;
- (void) stopSound:(NSString*)soundfile doDecay:(BOOL) decay;



@end
