//
//  BZDataModel.m
//
//  Copyright Trollwerks Inc 2010 All rights reserved.
//

#import "BZDataModel.h"
#import "BallZOutAppDelegate.h"
#import "TWXUIAlertView.h"

// Leaderboard Category IDs
#define kLeaderboardID @"ballzout.totalscore"

//Achievement IDs
NSString *kAchievementAllBalls5 = @"ballzout.ballz5";
NSString *kAchievementAllBalls10 = @"ballzout.ballz10";
NSString *kAchievementAllLives10 = @"ballzout.lives10";
NSString *kAchievementAllLives20 = @"ballzout.lives20";
NSString *kAchievementPerfectSkillz5 = @"ballzout.skillz5";
NSString *kAchievementPerfectSkillz10 = @"ballzout.skillz10";
NSString *kAchievementCombo3 = @"ballzout.combo3";
NSString *kAchievementCombo5 = @"ballzout.combo5";

NSString *kGameCenterEnableChangeNotification = @"GCEnableChange";
NSString *kGameCenterLoginResolvedNotification = @"GCLoginResolved";

//#define GAMECENTER_RESET_ACHIEVEMENTS 1

@implementation BZDataModel

@synthesize gameCenterManager;
@synthesize gameCenterLoginResolved;
@synthesize currentGame;

- (id)init 
{
	self = [super init];
	if (self != nil)
   {
      if ([GameCenterManager isGameCenterAvailable])
      {
         self.gameCenterManager= [[[GameCenterManager alloc] init] autorelease];
         [self.gameCenterManager setDelegate: self];
         
         if (self.gameCenterOn)
         {
            [self.gameCenterManager authenticateLocalUser];
         }
         else
         {
            gameCenterLoginResolved = YES;
         }
         
         [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(gameCenterAuthenticationChanged:)
            name:GKPlayerAuthenticationDidChangeNotificationName
            object:nil
          ];
      }
      else
      {
         gameCenterLoginResolved = YES;
         twlog("Game Center not available!");
      }
   }
	return self;
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];

   twrelease(gameCenterManager);
   twrelease(currentGame);
	
	[super dealloc];
}

#pragma mark -
#pragma mark Application support

- (BOOL)isGameSaved
{
   id game = [[NSUserDefaults standardUserDefaults] objectForKey:kBZPrefCurrentGame];
   return nil != game;
}

- (void)startGame
{
   [self endGame:self.currentGame];
   self.currentGame = [[[BZGame alloc] init] autorelease];
}

- (void)loadGame
{
   NSData *state = [[[[NSUserDefaults standardUserDefaults] objectForKey:kBZPrefCurrentGame] retain] autorelease];
   if (!state.length)
   {
      [self startGame];
      return;
   }
   
   BZGame *loadedGame = [NSKeyedUnarchiver unarchiveObjectWithData:state];
   if (loadedGame)
   {
      [self endGame:self.currentGame];
      self.currentGame = loadedGame;
   }
   else
   {
      twlog("error loading game!");
      [self startGame];
   }
}

- (void)endGame:(BZGame *)game
{
   if (game != self.currentGame)
   {
      twlog("trying to end a tutorial, we hope?");
      return;
   }
   
   self.currentGame = nil;
   
   [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBZPrefCurrentGame];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)save
{
   if (!currentGame || currentGame.isGameWon || currentGame.isGameLost)
   {
      // this'll happen if we quit during a win/lose display, no doubt
      [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBZPrefCurrentGame];
      [[NSUserDefaults standardUserDefaults] synchronize];
   }
   else
      [currentGame saveState:YES];
}

- (BOOL)gameCenterAvailable
{
   return nil != self.gameCenterManager;
}

- (BOOL)gameCenterOn
{
   BOOL gameCenterOn = [[NSUserDefaults standardUserDefaults] boolForKey:kBZPrefUseGameCenter];
   return gameCenterOn;
}

- (void)toggleGameCenter
{
   BOOL gameCenterOn = !self.gameCenterOn;
   [self enableGameCenter:gameCenterOn];
}

- (void)enableGameCenter:(BOOL)enabled
{
   [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kBZPrefUseGameCenter];
   [[NSUserDefaults standardUserDefaults] synchronize];
   
   if (enabled)
   {
      twcheck(self.gameCenterManager);
      if (self.gameCenterManager)
      {
         gameCenterLoginResolved = NO;
         [self.gameCenterManager authenticateLocalUser];
      }
   }
   else
   {
      // this crashed when called from within block handler?
      // probably because main scene didn't stop listening on dealloc.
      [self performSelector:@selector(notifyGameCenterLoginResolved) withObject:nil afterDelay:0];
   }

   [[NSNotificationCenter defaultCenter]
      postNotificationName:kGameCenterEnableChangeNotification
      object:self
      userInfo:nil
   ];         

   // presumably if it's turned off, we just stop reporting
}

- (void)gameCenterAuthenticationChanged:(NSNotification *)note
{
   // http://stackoverflow.com/questions/3749772/gamekit-notification-when-user-change
	
   twlog("gameCenterAuthenticationChanged! -- %@\n object (%@) %@\n  userInfo: %@", note, NSStringFromClass([note.object class]), note.object, note.userInfo);
   
   GKPlayer *notedPlayer = note.object;
   
   // looks like we get two of these on first start; (null) and the newly authenticated one
   // actually, looks like we always get the one being not authenticated, then later on the authenticated one
   if (!notedPlayer.playerID.length)
      return;
   
   GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
   twcheck([notedPlayer isEqual:localPlayer]);
   
   if (localPlayer.isAuthenticated)
   {
      twlog("local player authenticated -- %@", localPlayer);
      // assume they mean to turn it on
      [self enableGameCenter:YES];
      
      // should we detect player change and offer to end game?
   }
   else
   {
      twlog("local player not authenticated -- %@", localPlayer);
      // assume they mean to turn it off
      [self enableGameCenter:NO];
   }
}

- (void)reportScore:(int64_t)score
{
   if (!self.gameCenterManager)
      return;
   if (!self.gameCenterOn)
      return;
   if (score < gameCenterHighScore)
      return;
   
   twlog("reporting score: %lld", score);
   gameCenterHighScore = score;
   [self.gameCenterManager reportScore:score forCategory:kLeaderboardID];
}

- (void)reportAchievement:(NSString *)achievement percent:(double)percent;
{
   if (!self.gameCenterManager)
      return;
   if (!self.gameCenterOn)
      return;
  
   twlog("reporting achievement: %@", achievement);
   [self.gameCenterManager submitAchievement:achievement percentComplete:percent];
}

- (void)notifyGameCenterLoginResolved
{
   gameCenterLoginResolved = YES;
   [[NSNotificationCenter defaultCenter]
    postNotificationName:kGameCenterLoginResolvedNotification
    object:self
    userInfo:nil
    ];         
}

- (void)savePendingAchievement:(NSString *)achievement
{
   twlog("called savePendingAchievement: %@", achievement);
   if (!self.gameCenterManager)
      return;
   if (!self.gameCenterOn)
      return;
   GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
   //if (localPlayer.isAuthenticated)
      //return;
   NSString *playerID = localPlayer.playerID;
   if (!playerID.length)
      return;
   twlog("ok to save pending achievement: %@", achievement);

   NSArray *oldPending = [[NSUserDefaults standardUserDefaults] objectForKey:playerID];
   NSInteger pendingScore = achievement.integerValue;
   
   NSMutableArray *newPending = [NSMutableArray array];
   if (1 > pendingScore)
   {
      twlog("pending achievement: %@", achievement);
     [newPending addObject:achievement];
   }
   for (NSString *pending in oldPending)
   {
      // numeric score gets maxed with new one if necessary
      NSInteger oldPendingScore = pending.integerValue;
      if ((0 < oldPendingScore) && (0 < pendingScore))
      {
         pendingScore = MAX(pendingScore, oldPendingScore);
         continue;
      }
      
      if (![pending isEqual:achievement])
      {
         twlog("old pending achievement: %@", pending);
         [newPending addObject:pending];
      }
   }
   if (0 < pendingScore)
   {
      NSString *score = [NSString stringWithFormat:@"%d", pendingScore];
      [newPending addObject:score];
      twlog("pending max(new,old) score: %@", score);
   }

   [[NSUserDefaults standardUserDefaults] setObject:newPending forKey:playerID];
}

- (void)submitPendingAchievements
{
   twlog("submitPendingAchievements called ...");
   if (!self.gameCenterManager)
      return;
   if (!self.gameCenterOn)
      return;
   GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
   if (!localPlayer.isAuthenticated)
      return;
   NSString *playerID = localPlayer.playerID;
   if (!playerID.length)
      return;
   
   twlog(" ... and submitting!");
   NSArray *pending = [[NSUserDefaults standardUserDefaults] objectForKey:playerID];
   if (!pending)
     return;
   pending = [[pending copy] autorelease];
   [[NSUserDefaults standardUserDefaults] removeObjectForKey:playerID];
  
   for (NSString *achievement in pending)
   {
      NSInteger score = achievement.integerValue;
      if (0 < score)
         [self reportScore:score];
      else
         [self reportAchievement:achievement percent:100];
   }
}

#pragma mark -
#pragma mark GameCenterManagerDelegate

- (void)processGameCenterAuth:(NSError *)error
{
	if (error == NULL)
	{
      //twlog("processGameCenterAuth WIN! -- call reloadHighScoresForCategory?");
      gameCenterHighScore = 0;
#if GAMECENTER_RESET_ACHIEVEMENTS
#warning resetting achievements!
      twlog("resetting achievements!");
      [self.gameCenterManager resetAchievements];
#endif GAMECENTER_RESET_ACHIEVEMENTS
		[self.gameCenterManager reloadHighScoresForCategory:kLeaderboardID];

      // this crashed when called from within block handler?
      // probably because main scene didn't stop listening on dealloc.
      [self performSelector:@selector(notifyGameCenterLoginResolved) withObject:nil afterDelay:0];
   }
	else
	{
      twcheck([error.domain isEqual:GKErrorDomain]);
      
      twlog("processGameCenterAuth FAIL: %@", error);

      if (GKErrorCancelled == error.code)
      {
         // assume they mean to turn it off
         [self enableGameCenter:NO];

         // this crashed when called from within block handler?
         // probably because main scene didn't stop listening on dealloc.
         [self performSelector:@selector(notifyGameCenterLoginResolved) withObject:nil afterDelay:0];

         return;
      }
      
      NSString *message = [NSString stringWithFormat:NSLocalizedString(@"GAMECENTERMESSAGE", nil), error.localizedDescription];
      UIAlertView *gcFail = [UIAlertView twxOKAlert:@"GAMECENTERFAIL" withMessage:message];
      gcFail.delegate = self;
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   (void)alertView;
   (void)buttonIndex;
 
   // assume this is from GAMECENTERFAIL alert
   [self notifyGameCenterLoginResolved];
}

- (void) scoreReported:(NSError*) error;
{
   twlog("scoreReported called, error: %@", error);

	if (error == NULL)
	{
      /*
		[self.gameCenterManager reloadHighScoresForCategory: self.currentLeaderBoard];
		[self showAlertWithTitle: @"High Score Reported!"
                       message: [NSString stringWithFormat: @"", [error localizedDescription]]];
       */
	}
	else
	{
		// [self showAlertWithTitle: @"Score Report Failed!"
      // message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
      
      // save it for later
      NSString *score = [NSString stringWithFormat:@"%d", BZCurrentGame().score];
      [self savePendingAchievement:score];
	}
}

- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error;
{
   if (!error)
   {
      gameCenterHighScore = leaderBoard.localPlayerScore.value;
   
      twlog("reloadScoresComplete called, high score %lld; error: %@", gameCenterHighScore, error);

      [self submitPendingAchievements];
   }
   else
   {
      twlog("reloadScoresComplete FAIL -- %@!", error);
   }

   /*
	if(error == NULL)
	{
		int64_t personalBest= leaderBoard.localPlayerScore.value;
		self.personalBestScoreDescription= @"Your Best:";
		self.personalBestScoreString= [NSString stringWithFormat: @"%ld", personalBest];
		if([leaderBoard.scores count] >0)
		{
			self.leaderboardHighScoreDescription=  @"-";
			self.leaderboardHighScoreString=  @"";
			GKScore* allTime= [leaderBoard.scores objectAtIndex: 0];
			self.cachedHighestScore= allTime.formattedValue;
			[gameCenterManager mapPlayerIDtoPlayer: allTime.playerID];
		}
	}
	else
	{
		self.personalBestScoreDescription= @"GameCenter Scores Unavailable";
		self.personalBestScoreString=  @"-";
		self.leaderboardHighScoreDescription= @"GameCenter Scores Unavailable";
		self.leaderboardHighScoreDescription=  @"-";
		[self showAlertWithTitle: @"Score Reload Failed!"
                       message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
	[self.tableView reloadData];
    */
}

- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error;
{
   twlog("achievementSubmitted called, ach %@; error: %@", ach, error);

	if((error == NULL) && (ach != NULL))
	{
      /*
		if(ach.percentComplete == 100.0)
		{
			[self showAlertWithTitle: @"Achievement Earned!"
                          message: [NSString stringWithFormat: @"Great job!  You earned an achievement: \"%@\"", NSLocalizedString(ach.identifier, NULL)]];
		}
		else
		{
			if(ach.percentComplete > 0)
			{
				[self showAlertWithTitle: @"Achievement Progress!"
                             message: [NSString stringWithFormat: @"Great job!  You're %.0f\%% of the way to: \"%@\"",ach.percentComplete, NSLocalizedString(ach.identifier, NULL)]];
			}
		}
       */
	}
	else
	{
		//[self showAlertWithTitle: @"Achievement Submission Failed!"
      //                 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
      
      // save it for later
      [self savePendingAchievement:ach.identifier];
	}
}

- (void) achievementResetResult: (NSError*) error
{
   twlog("achievementResetResult called, error: %@", error);
/*
	self.currentScore= 0;
	[self.tableView reloadData];
	if(error != NULL)
	{
		[self showAlertWithTitle: @"Achievement Reset Failed!"
                       message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
	}
 */
}

- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error
{
   twlog("mappedPlayerIDToPlayer called, player %@; error: %@", player, error);
   /*
	if((error == NULL) && (player != NULL))
	{
		self.leaderboardHighScoreDescription= [NSString stringWithFormat: @"%@ got:", player.alias];
		
		if(self.cachedHighestScore != NULL)
		{
			self.leaderboardHighScoreString= self.cachedHighestScore;
		}
		else
		{
			self.leaderboardHighScoreString= @"-";
		}
      
	}
	else
	{
		self.leaderboardHighScoreDescription= @"GameCenter Scores Unavailable";
		self.leaderboardHighScoreDescription=  @"-";
	}
	[self.tableView reloadData];
    */
}

@end
