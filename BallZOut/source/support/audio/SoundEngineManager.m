//
//  SoundEngineManager.m
//
//  Created by Hoan Ton-That on 7/21/08.
//  Modified by Ricardo Quesada
//

#import "SoundEngineManager.h"
#import "SoundEngine.h"

#if TARGET_IPHONE_SIMULATOR
#define NO_SOUND 0
#else
#define NO_SOUND 0
#endif TARGET_IPHONE_SIMULATOR

@implementation SoundEngineManager

@synthesize currentTrack;

static SoundEngineManager *sharedSoundEngineManager;
static float frequency = 44100;

// Init
+ (SoundEngineManager *) sharedManager
{
	@synchronized(self)	{
		if (!sharedSoundEngineManager)
			[[SoundEngineManager alloc] initWithFrequency:frequency];
		
		return sharedSoundEngineManager;
	}
	// to avoid compiler warning
	return nil;
}

+ (id) alloc
{
	@synchronized(self)	{
		NSAssert(sharedSoundEngineManager == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedSoundEngineManager = [super alloc];
		return sharedSoundEngineManager;
	}
	// to avoid compiler warning
	return nil;
}

+(void) setFrequency:(float) freq
{
	frequency = freq;
}

- (id) init
{
	return [self initWithFrequency:44100];
}

-(id) initWithFrequency: (float) freq
{
	if(![super init]) return nil;
	
	bundle = [[NSBundle mainBundle] retain];

	currentTrack = nil;
	playing = NO;
	
	if(SoundEngine_Initialize(freq) != noErr) {
		twlog("SoundEngineManager: Could not initialize");
		return nil;	
	}
	if( SoundEngine_SetListenerPosition(0.0f, 0.0f, 1.0f) != noErr) {
		twlog("SoundEngineManager: Could not set listener position");
		return nil;	
	}

	// sound effect specific
	sounds = [[NSMutableDictionary dictionaryWithCapacity: 32] retain];

	muted = NO;

	return self;
}

-(void) shutdown
{
	[bundle release];
	[sounds release];
	SoundEngine_Teardown();
}

// Memory
- (void) dealloc
{
	[currentTrack release];
	[bundle release];
	[sounds release];
	
	sharedSoundEngineManager = nil;

	UInt32 result = noErr;
	
	result = SoundEngine_Teardown();
	if (result != noErr) {
		twlog("ERROR: SoundEngine_Teardown");
	}
		
	[super dealloc];
}

//
// Background Music related
//

// Playing
- (void) playTrack:(NSString*)soundfile
{
   (void)soundfile;
   
#if !NO_SOUND
	OSStatus result = noErr;
	
	NSString *path = [bundle pathForResource:soundfile ofType:nil];
	
	// If not already playing
	if(!muted &&
		(!currentTrack || ![currentTrack isEqualToString:path]) ) {
		[self stop];

		result = SoundEngine_LoadBackgroundMusicTrack([path cStringUsingEncoding:NSASCIIStringEncoding], false, true);

		if (result != noErr) {
			twlog("ERROR: SoundEngine_LoadBackgroundMusicTrack");
			return;
		}

		// Set the current track
		[currentTrack release];
		currentTrack = [path retain];
		
		// Play
		SoundEngine_StartBackgroundMusic();
		playing = YES;
	}
#endif
}

- (void) stop
{
	
#if !NO_SOUND
	OSStatus result = noErr;
	
	// If already playing
	if(currentTrack) {
		result = SoundEngine_StopBackgroundMusic(false);
		if (result != noErr) {
			twlog("ERROR: SoundEngine_StopBackgroundMusic");
			return;
		}
		
		// Unload track
		SoundEngine_UnloadBackgroundMusicTrack();
		
		// Set the current track
		[currentTrack release];
		currentTrack = nil;
		playing = NO;
	}
#endif
}

- (void) pause
{

#if !NO_SOUND
	OSStatus result = noErr;
	
	// If already playing
	if(currentTrack && playing) {
		result = SoundEngine_PauseBackgroundMusic();
		playing = NO;

		if (result != noErr) {
			twlog ("ERROR: SoundEngine_StopBackgroundMusic");
			return;
		}
	}
#endif
}

- (void) resume
{

#if !NO_SOUND
	OSStatus result = noErr;
	
	// If already playing
	if(!muted && currentTrack && !playing) {
		result = SoundEngine_StartBackgroundMusic();
		if (result != noErr) {
			twlog("ERROR: SoundEngine_StartBackgroundMusic");
			return;
		}
		playing = YES;
	}
#endif
}

//
// Sound Effect related
// 

// Adding sounds
- (NSNumber *) addSound:(NSString *)soundfile
{
   (void)soundfile;

#if !NO_SOUND
	NSNumber *number;
	
	if( (number = [sounds objectForKey: soundfile]) ) {
		// XXX: don't autorelease for performance
		return number;
	}
	
	UInt32 soundId;
	NSString *name = [bundle pathForResource:soundfile ofType:nil];
	if( SoundEngine_LoadEffect( [name cStringUsingEncoding:NSASCIIStringEncoding], &soundId) != noErr ) {
		twlog("Can't load %@", soundfile );
		NSAssert(0,@"Failed to load sound");
		return nil;
	}
	
	number = [NSNumber numberWithInt:soundId];	
	[sounds setObject:number forKey:soundfile];
	
	// XXX: don't autorelease for performance
	return number;
#else
	return nil;
#endif
}

-(void) removeSound:(NSString*) soundfile
{
   (void)soundfile;

#if !NO_SOUND
	NSNumber *number;
	if ( (number = [sounds objectForKey: soundfile]) ) {
		SoundEngine_UnloadEffect( [number intValue] );
		[sounds removeObjectForKey:soundfile];
	}
#endif
}

// Playing
- (void) playSound:(NSString*)soundfile
{
   (void)soundfile;

#if !NO_SOUND
	NSNumber *sound = [self addSound:soundfile];
	if(sound && !muted)
		SoundEngine_StartEffect( [sound intValue] );
#endif
}

- (void) stopSound:(NSString*)soundfile doDecay:(BOOL)decay
{
   (void)soundfile;
   (void)decay;

#if !NO_SOUND
	NSNumber *sound = [self addSound:soundfile];
	if(sound)
		SoundEngine_StopEffect( [sound intValue], decay );
#endif
}

-(BOOL) muted
{
	return muted;
}

-(void) setMuted: (BOOL) m
{
	muted = m;
	if( m ) {
		[self pause];
	} else {
		[self resume];
	}
}
@end
