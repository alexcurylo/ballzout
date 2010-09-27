//
//  BZDataModel.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "BZGame.h"

@interface BZDataModel : NSObject
{
   BZGame *currentGame;
}

@property (nonatomic, retain) BZGame *currentGame;

#pragma mark -
#pragma mark Life cycle

- (id)init;
- (void)dealloc;

#pragma mark -
#pragma mark Application support

- (void)startNewGame;
- (void)endGame;

/*
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
