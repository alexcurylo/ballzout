//
//  BZGame.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

enum
{
   kGameLivesCount = 3,
   
   kLifeBallsCount = 3,

   kScoreOneBallOut = 100,
   
   kArenaFileCount = 9,
   
   kGameLevelCount = 3,
};

@interface BZGame : NSObject
{
   NSInteger lives;
   NSInteger balls;
   NSInteger level;
   NSInteger score;
}

@property (nonatomic, assign) NSInteger lives;
@property (nonatomic, assign) NSInteger balls;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger score;

#pragma mark -
#pragma mark Life cycle

- (id)init;
- (void)dealloc;

#pragma mark -
#pragma mark Level support

- (NSString *)currentLevelFileName;
- (NSString *)currentArenaFileName;

- (void)targetOut;
- (void)ballOut;
- (void)levelLost;
- (void)levelWon;

- (BOOL)isGameWon;
- (BOOL)isGameLost;

/*

#pragma mark -
#pragma mark Application support

- (void)load;
- (void)save;

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
