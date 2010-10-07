//
//  BZDataModel.h
//
//  Copyright Trollwerks Inc 2010. All rights reserved.
//

#import "BZGame.h"
#import "GameCenterManager.h"

extern NSString *kAchievementAllBalls5; // = @"ballzout.ballz5";
extern NSString *kAchievementAllBalls10; // = @"ballzout.ballz10";
extern NSString *kAchievementAllLives10; // = @"ballzout.lives10";
extern NSString *kAchievementAllLives20; // = @"ballzout.lives20";
extern NSString *kAchievementPerfectSkillz5; // = @"ballzout.skillz5";
extern NSString *kAchievementPerfectSkillz10; // = @"ballzout.skillz10";
extern NSString *kAchievementCombo3; // = @"ballzout.combo3";
extern NSString *kAchievementCombo5; // = @"ballzout.combo5";

extern NSString *kGameCenterEnableChangeNotification; // = @"GCEnableChange";
extern NSString *kGameCenterLoginResolvedNotification; // = @"GCLoginResolved";

@interface BZDataModel : NSObject < GameCenterManagerDelegate >
{
 	GameCenterManager* gameCenterManager;
   int64_t gameCenterHighScore;
   BOOL gameCenterLoginResolved;

   BZGame *currentGame;
}

@property (nonatomic, retain) GameCenterManager *gameCenterManager;
@property (nonatomic, assign) BOOL gameCenterLoginResolved;
@property (nonatomic, retain) BZGame *currentGame;

#pragma mark -
#pragma mark Life cycle

- (id)init;
- (void)dealloc;

#pragma mark -
#pragma mark Application support

- (BOOL)isGameSaved;

- (void)startGame;
- (void)loadGame;
- (void)endGame:(BZGame *)game;

- (void)save;

- (BOOL)gameCenterAvailable;
- (BOOL)gameCenterOn;
- (void)toggleGameCenter;
- (void)enableGameCenter:(BOOL)enabled;
- (void)gameCenterAuthenticationChanged:(NSNotification *)note;
- (void)reportScore:(int64_t)score;
- (void)reportAchievement:(NSString *)achievement percent:(double)percent;
- (void)notifyGameCenterLoginResolved;

- (void)savePendingAchievement:(NSString *)achievement;
- (void)submitPendingAchievements;

#pragma mark -
#pragma mark GameCenterManagerDelegate

- (void) processGameCenterAuth: (NSError*) error;
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void) scoreReported: (NSError*) error;
- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error;
- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error;
- (void) achievementResetResult: (NSError*) error;
- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error;

@end
