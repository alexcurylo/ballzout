//
//  BZDataModel.m
//
//  Copyright Trollwerks Inc 2010 All rights reserved.
//

#import "BZDataModel.h"

@implementation BZDataModel

@synthesize currentGame;

- (id)init
{
	self = [super init];
	if (self != nil)
   {
      /*
      [self load];

      self.pollingTimer = [NSTimer
         scheduledTimerWithTimeInterval:10.
         target:self
         selector:@selector(pollingTimerFired:)
         userInfo:nil
         repeats:YES
      ];
       */
   }
	return self;
}

- (void)dealloc
{
   /*
    [self.pollingTimer invalidate];
   self.pollingTimer = nil;
	self.storedMessages = nil;
	self.triggeredMessages = nil;
	self.sentMessages = nil;
	self.missingMessages = nil;
	self.triggeringMessage = nil;
    */
   
   twrelease(currentGame);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Application support

- (void)startNewGame
{
   [self endGame];
   self.currentGame = [[[BZGame alloc] init] autorelease];
}

- (void)endGame
{
   self.currentGame = nil;
}

/*
- (void)load
{
   self.storedMessages = [NSMutableArray array];
   self.triggeredMessages = [NSMutableArray array];
   self.sentMessages = [NSMutableArray array];
   self.missingMessages = [NSMutableArray array];

//#define CLEAR_SAVED_MESSAGES 1
#if CLEAR_SAVED_MESSAGES
#warning clearing out saved messages
   twlog("not loading saved messages...");
   return;
#endif CLEAR_SAVED_MESSAGES
   
	NSError *error = nil;
   NSArray *savedMessages = nil;
	NSData *savedStateFile = [NSData
      dataWithContentsOfFile:[@"~/Documents/storedMessages.state" stringByExpandingTildeInPath] 
      options:NSUncachedRead 
      error:&error
   ];
	if (!error)
	{
		savedMessages = [NSKeyedUnarchiver unarchiveObjectWithData:savedStateFile];
		for (TMMessage *message in savedMessages)
         [self.storedMessages addObject:message];
	}
 	else
   {
		twlog("error restoring storedMessages.state: %@", [error localizedDescription]);
   }

	error = nil;
   savedMessages = nil;
	savedStateFile = [NSData
      dataWithContentsOfFile:[@"~/Documents/sentMessages.state" stringByExpandingTildeInPath] 
      options:NSUncachedRead 
      error:&error
   ];
	if (!error)
	{
		savedMessages = [NSKeyedUnarchiver unarchiveObjectWithData:savedStateFile];
		for (TMMessage *message in savedMessages)
         [self.sentMessages addObject:message];
	}
 	else
   {
		twlog("error restoring sentMessages.state: %@", [error localizedDescription]);
   }
}

- (void)save
{
	NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.storedMessages];
	[encodedObject writeToFile:[@"~/Documents/storedMessages.state" stringByExpandingTildeInPath] atomically:YES];

	encodedObject = [NSKeyedArchiver archivedDataWithRootObject:self.sentMessages];
	[encodedObject writeToFile:[@"~/Documents/sentMessages.state" stringByExpandingTildeInPath] atomically:YES];
}

- (void)fixNotificationTypes
{
   for (TMMessage *storedMessage in self.storedMessages)
      [storedMessage fixNotificationTypes];
   [self save];
}

- (void)startHandlingMessage
{
   twcheck(!self.currentlyHandlingMessage);
   self.currentlyHandlingMessage = YES;
}

- (void)endHandlingMessage
{
   twcheck(self.currentlyHandlingMessage);
   self.currentlyHandlingMessage = NO;
   [self pollingTimerFired:nil];
}

#if USE_APNS
- (void)syncILimeURL
{
   NSString *deviceUrlText = [[NSUserDefaults standardUserDefaults] objectForKey:kILimeDeviceURLKey];
   if (!deviceUrlText.length)
      deviceUrlText = @"";
      //return;
   
   NSString *deviceAuthorization = [[iLimeService shared] basicAuthorizationString];
      
   NSURL *ilimeURL = [TWAppDelegate() serverURLForPath:@"ilime"];
   TWURLConnection *ilimer = [[TWURLConnection alloc] initWithURL:ilimeURL delegate:self userInfo:kConnection_ILime];
   
   [ilimer startFormPOST];
   
   [ilimer appendFormFieldString:@"udid" string:[UIDevice currentDevice].uniqueIdentifier];
   [ilimer appendFormFieldString:@"url" string:deviceUrlText];
   [ilimer appendFormFieldString:@"auth" string:deviceAuthorization];

   [ilimer completeFormPOST];
      
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
   [ilimer startLoading];   
}
#endif USE_APNS

#if USE_APNS
- (void)syncMissingMessage
{
   if (!self.missingMessages.count)
      return;
   
   NSURL *retrieveURL = [TWAppDelegate() serverURLForPath:@"retrieve"];
   TWURLConnection *retriever = [[TWURLConnection alloc] initWithURL:retrieveURL delegate:self userInfo:kConnection_Missing];
   
   [retriever startFormPOST];
   
   [retriever appendFormFieldString:@"msgkey" string:[self.missingMessages objectAtIndex:0]];
   
   [retriever completeFormPOST];
   
   [self.missingMessages removeObjectAtIndex:0];
   
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
   [retriever startLoading];
}
#endif USE_APNS

#if USE_APNS
- (void)handleMissingResults:(NSArray *)fields
{
   if (fields.count < 2)
      return;

   NSString *kTargetPrefix = @"target=";
   NSString *kSendPrefix = @"send=";
   NSString *kMethodPrefix = @"method=";
   NSString *kOccurPrefix = @"occur=";
   NSString *kTextPrefix = @"text=";
   NSString *kKeyPrefix = @"key=";

   TMMessage *message = [TMMessage emptyMessage];
   for (NSString *field in fields)
   {
      if ([field hasPrefix:kTargetPrefix])
      {
         message.target = [field substringFromIndex:kTargetPrefix.length];
      }
      else if ([field hasPrefix:kSendPrefix])
      {
         NSString *seconds = [field substringFromIndex:kSendPrefix.length];
         NSDate *date = [NSDate dateWithTimeIntervalSince1970:seconds.floatValue];
         message.send = date;
      }
      else if ([field hasPrefix:kMethodPrefix])
      {
         message.method = [field substringFromIndex:kMethodPrefix.length];
      }
      else if ([field hasPrefix:kOccurPrefix])
      {
         message.occur = [field substringFromIndex:kOccurPrefix.length];
      }
      else if ([field hasPrefix:kTextPrefix])
      {
         message.text = [field substringFromIndex:kTextPrefix.length];
      }
      else if ([field hasPrefix:kKeyPrefix])
      {
         message.key = [field substringFromIndex:kKeyPrefix.length];
      }
      else
      {
         twlog("what field is this? -- %@", field);
      }
   }
   
   [self.storedMessages addObject:message];
   [[NSNotificationCenter defaultCenter] postNotificationName:kStoredMessagesChangedNotification object:self];
   [self save];

   [self syncMissingMessage];
}
#endif USE_APNS

- (BOOL)keyInStoredMessages:(NSString *)key
{
   if (!key.length)
      return YES;
   
   for (TMMessage *message in self.storedMessages)
      if ([key isEqualToString:message.key])
         return YES;
   
   return NO;
}

#if USE_APNS
- (void)handleSyncResults:(NSArray *)actives
{
   NSMutableArray *extras = [NSMutableArray array];
   for (TMMessage *message in self.storedMessages)
      if (NSNotFound == [actives indexOfObject:message.key])
      {
         twlog("Extra message: %@!", message);
         [extras addObject:message];
      }
   if (extras.count)
   {
      [self.storedMessages removeObjectsInArray:extras];
      [[NSNotificationCenter defaultCenter] postNotificationName:kStoredMessagesChangedNotification object:self];
      [self save];
   }
         
   for (NSString *key in actives)
      if (![self keyInStoredMessages:key])
      {
         twlog("Missing key: %@!", key);
         [self.missingMessages addObject:key];
      }
   [self syncMissingMessage];
}
#endif USE_APNS

#if USE_APNS
- (void)syncWithServer
{
   NSURL *syncURL = [TWAppDelegate() serverURLForPath:@"active"];
   TWURLConnection *syncer = [[TWURLConnection alloc] initWithURL:syncURL delegate:self userInfo:kConnection_Sync];

   [syncer startFormPOST];
   
   [syncer appendFormFieldString:@"device" string:[UIDevice currentDevice].uniqueIdentifier];
      
   [syncer completeFormPOST];
   
   [UIApplication sharedApplication].networkActivityIndicatorVisible = YES; 
   [syncer startLoading];
}
#endif USE_APNS

- (void)addMessage:(TMMessage *)message
{
#if USE_APNS
   [message storeOnServer];
#elif USE_LOCAL_NOTIFICATIONS
   [message storeLocalNotification];
#else
#error how shall we addMessage?
#endif USE_APNS
  
   [self.storedMessages addObject:message];
   [self.storedMessages sortUsingSelector:@selector(compareByDate:)];
   [[NSNotificationCenter defaultCenter] postNotificationName:kStoredMessagesChangedNotification object:self];
   [self save];
}

- (void)editMessage:(TMMessage *)message
{
#if USE_APNS
   [message editOnServer];
#elif USE_LOCAL_NOTIFICATIONS
   [message editLocalNotification];
#else
#error how shall we editMessage?
#endif USE_APNS

   [self.storedMessages sortUsingSelector:@selector(compareByDate:)];
   [[NSNotificationCenter defaultCenter] postNotificationName:kStoredMessagesChangedNotification object:self];
   [self save];
}

- (void)deleteStoredMessage:(TMMessage *)message
{
   twcheck(message);
#if USE_APNS
   [message deleteOnServer];
#elif USE_LOCAL_NOTIFICATIONS
   [message deleteLocalNotification];
#else
#error how shall we deleteStoredMessage?
#endif USE_APNS
   
   [self.storedMessages removeObject:message];
   [[NSNotificationCenter defaultCenter] postNotificationName:kStoredMessagesChangedNotification object:self];
   [self save];
}

- (void)deleteAllStoredMessages
{
   for (TMMessage *message in self.storedMessages)
#if USE_APNS
      [message deleteOnServer];
#elif USE_LOCAL_NOTIFICATIONS
      [message deleteLocalNotification];
#else
#error how shall we deleteAllStoredMessages?
#endif USE_APNS
    
   [self.storedMessages removeAllObjects];
   [[NSNotificationCenter defaultCenter] postNotificationName:kStoredMessagesChangedNotification object:self];
   [self save];
}

- (void)deleteSentMessage:(TMMessage *)message
{
   twcheck(message);
   [self.sentMessages removeObject:message];
   [[NSNotificationCenter defaultCenter] postNotificationName:kSentMessagesChangedNotification object:self];
   [self save];
}

- (void)deleteAllSentMessages
{
   [self.sentMessages removeAllObjects];
   [[NSNotificationCenter defaultCenter] postNotificationName:kSentMessagesChangedNotification object:self];
   [self save];
}

- (void)triggerMessage:(NSString *)messageKey
{
   if (!messageKey.length)
   {
      twlog("triggerMessage given null/empty key!");
      return;
   }
   
   if (self.currentlyHandlingMessage)
   {
      twlog("triggerMessage -- already handling a message!");
      return;
   }

   if ([TMMessageViewController isEditing:messageKey])
   {
      twlog("triggerMessage -- is editing it!");
      return;
   }
   
   [self startHandlingMessage];
   
   //twlog("triggered sending message key: %@", messageKey);
   
   TMMessage *triggeredMessage = nil;
   for (TMMessage *storedMessage in self.storedMessages)
      if ([storedMessage.key isEqual:messageKey])
      {
         triggeredMessage = storedMessage;
         break;
      }
   if (!triggeredMessage)
      for (TMMessage *sentMessage in self.sentMessages)
         if ([sentMessage.key isEqual:messageKey])
         {
            twlog("triggeredMessage was found in sent list??");
            triggeredMessage = sentMessage;
            break;
         }
   if (!triggeredMessage)
   {
      twlog("FAIL: triggeredMessage %@ could not be found!", messageKey);
      [self endHandlingMessage];
      return;
   }
   
   self.triggeringMessage = triggeredMessage;
   NSString *triggerText = [NSString stringWithFormat:NSLocalizedString(@"TRIGGERTEXT", nil), triggeredMessage.text, triggeredMessage.targetDescription];
   NSInteger snoozeMinutes = [[NSUserDefaults standardUserDefaults] integerForKey:kTMPrefSnoozeMinutes];
   NSString *format = NSLocalizedString(1 == snoozeMinutes ? @"TRIGGERSNOOZEMINUTE" : @"TRIGGERSNOOZEMINUTES", nil);
   NSString *snoozeText = [NSString stringWithFormat:format, snoozeMinutes];
   UIActionSheet *triggerAction = [[[UIActionSheet alloc]
      initWithTitle:triggerText
      delegate:self
      cancelButtonTitle:NSLocalizedString(@"TRIGGERDELETE", nil) // bottom, black
      destructiveButtonTitle:NSLocalizedString(@"TRIGGERSEND", nil) // top, red, 0
      otherButtonTitles:snoozeText, // middle, grey, 1
      nil
   ] autorelease];
   [triggerAction showFromTabBar:TWAppDelegate().tabBarController.tabBar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
   (void)actionSheet;
   //twlog("action sheet clickedButtonAtIndex %i", buttonIndex);

   switch (buttonIndex)
   {
      case kTriggerSendButton:
         {            
         [self.sentMessages addObject:[self.triggeringMessage sentMessage]];
         [[NSNotificationCenter defaultCenter] postNotificationName:kSentMessagesChangedNotification object:self];

         [self.storedMessages removeObject:self.triggeringMessage];
         TMMessage *nextMessage = [self.triggeringMessage nextScheduled];
         if (nextMessage)
         {
#if USE_APNS
            // notification will come as scheduled, we imagine
            [self.storedMessages addObject:nextMessage];
            [[NSNotificationCenter defaultCenter] postNotificationName:kStoredMessagesChangedNotification object:self];
            [self save];
#elif USE_LOCAL_NOTIFICATIONS
            // always add them as UILocalNotification can't schedule random reminders
            [self addMessage:nextMessage];
#else
#error how shall we handle scheduling next?
#endif USE_APNS
         }
         else
         {
            [[NSNotificationCenter defaultCenter] postNotificationName:kStoredMessagesChangedNotification object:self];
            [self save];
         }
         
         // this will presumably leave the application -- nope, 
         [self.triggeringMessage trigger];
         }
         break;
         
      case kTriggerSnoozeButton:
         {
#if USE_LOCAL_NOTIFICATIONS
         TMMessage *snoozed = [self.triggeringMessage snoozedMessage];
         [self.storedMessages removeObject:self.triggeringMessage];
         // always add them as UILocalNotification can't schedule random reminders
         [self addMessage:snoozed];
#else
#error how shall we handle snoozing?
#endif USE_LOCAL_NOTIFICATIONS
         [self endHandlingMessage];
         }
        break;
         
      case kTriggerDeleteButton:
         [self.storedMessages removeObject:self.triggeringMessage];
         [[NSNotificationCenter defaultCenter] postNotificationName:kStoredMessagesChangedNotification object:self];
         [self save];
         [self endHandlingMessage];
         break;
         
      default:
         twlog("what should button index %i do?", buttonIndex);
         break;
   }
}

- (void)pollingTimerFired:(NSTimer *)timer
{
   (void)timer;
   
   if (self.currentlyHandlingMessage)
      return;
   
   for (TMMessage *message in self.storedMessages)
      if ([message triggerIfFired])
         return;
   
   // nothing pending, so make sure badge goes away
   [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

}

#if USE_APNS
- (void)TWURLConnectionDidFinish:(TWURLConnection *)dataReceiver
{
   (void)dataReceiver;
   
   [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
   
   NSData* receivedData = [dataReceiver receivedData];
   NSString* result = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
   
   if ([kConnection_Sync isEqual:[dataReceiver userInfo]])
   {
      if (!result.length)
      {
         if (self.storedMessages.count)
         {
            [self.storedMessages removeAllObjects];
            [[NSNotificationCenter defaultCenter] postNotificationName:kStoredMessagesChangedNotification object:self];
            [self save];
         }
         twlog("sync(active) handled -- no actives");
      }
      else
      {
         NSArray *actives = [result componentsSeparatedByString:@","];
         [self handleSyncResults:actives];          
         twlog("sync(active) handled -- %d actives", actives.count);
      }
   }
   else if ([kConnection_Missing isEqual:[dataReceiver userInfo]])
   {
      NSArray *fields = [result componentsSeparatedByString:@"\n"];
      [self handleMissingResults:fields];          
      twlog("sync(missing) handled -- %d fields", fields.count);
   }
   else if ([kConnection_ILime isEqual:[dataReceiver userInfo]])
   {
      twlog("sync(ilime) handled");
   }
   else
   {
      twlog("what TMDataModel connection is %@?", [dataReceiver userInfo]);
   }
   
#if DEBUG
   twlog("TWURLConnectionDidFinish: %@", result);
#endif DEBUG
}
#endif USE_APNS
*/
@end
