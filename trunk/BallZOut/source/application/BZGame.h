//
//  BZGame.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

enum
{
   kGameLivesCount = 3,
   
   kLifeBallsCount = 3,

   kScoreOneBallOut = 200,
   
   kArenaFileCount = 16,

   kGameLevelCount = 4,
   kTutorialLevelCount = 1,
};

@interface BZGame : NSObject < NSCoding >
{
   BOOL isTutorial;
   
   NSInteger lives;
   NSInteger level;
   NSInteger score;

   NSInteger levelBalls;
   //NSInteger levelBallsInPlay;
   NSInteger levelScore;
   NSInteger levelShots;
   NSInteger levelAccurateShots;

   NSInteger shotMultiplier;
   
   NSInteger achievementAllBalls;
   NSInteger achievementAllLives;
   NSInteger achievementSkillz;
   NSInteger achievement3Ballz;
   NSInteger achievement5Ballz;
}

@property (nonatomic, assign) BOOL isTutorial;
@property (nonatomic, assign) NSInteger lives;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger levelBalls;
//@property (nonatomic, assign) NSInteger levelBallsInPlay;
@property (nonatomic, assign) NSInteger levelScore;
@property (nonatomic, assign) NSInteger levelShots;
@property (nonatomic, assign) NSInteger levelAccurateShots;
@property (nonatomic, assign) NSInteger levelMaxMultiplier;
@property (nonatomic, assign) NSInteger shotMultiplier;

#pragma mark -
#pragma mark Life cycle

- (id)init;
- (void)dealloc;

- (void)encodeWithCoder:(NSCoder *)coder;
- (id)initWithCoder:(NSCoder *)decoder;

#pragma mark -
#pragma mark Level support

- (NSString *)currentLevelFileName;
- (NSString *)currentArenaFileName;

- (void)targetOut;
- (void)ballShot;
- (void)ballStopped;
- (void)ballOut;

- (void)levelBegin;
- (void)levelLost;
- (void)levelWon;
- (void)reportInLevelAchievements;
- (NSInteger)levelAccuracy;
- (NSInteger)levelBonus;
- (NSInteger)levelTotal;

- (BOOL)isGameWon;
- (BOOL)isGameLost;

- (void)saveState:(BOOL)synchronize;

/*

#pragma mark -
#pragma mark Application support

- (void)fixNotificationTypes;

- (void)startHandlingMessage;
- (void)endHandlingMessage;

#if USE_APNS
- (void)syncILimeURL;

- (void)syncMissingMessage;
- (void)handleMissingResults:(NSArray *)fields;
#endif USE_APNS
- (BOOL)keyInStoredMessages:(NSString *)key;
#if USE_APNS
- (void)handleSyncResults:(NSArray *)actives;
- (void)syncWithServer;
#endif USE_APNS

- (void)addMessage:(TMMessage *)message;
- (void)editMessage:(TMMessage *)message;

- (void)deleteStoredMessage:(TMMessage *)message;
- (void)deleteAllStoredMessages;
- (void)deleteSentMessage:(TMMessage *)message;
- (void)deleteAllSentMessages;

- (void)triggerMessage:(NSString *)messageKey;
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)pollingTimerFired:(NSTimer *)timer;

#if USE_APNS
- (void)TWURLConnectionDidFinish:(TWURLConnection *)dataReceiver;
#endif USE_APNS
*/
@end
