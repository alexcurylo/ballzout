//
//  BZGame.m
//
//  Copyright Trollwerks Inc 2010 All rights reserved.
//

#import "BZGame.h"
#import "BallZOutAppDelegate.h"

@implementation BZGame

@synthesize isTutorial;
@synthesize lives;
@synthesize level;
@synthesize score;
@synthesize levelBalls;
//@synthesize levelBallsInPlay;
@synthesize levelScore;
@synthesize levelShots;
@synthesize levelAccurateShots;
@synthesize levelMaxMultiplier;
@synthesize shotMultiplier;

#pragma mark -
#pragma mark Life cycle

- (id)init
{
	self = [super init];
	if (self != nil)
   {
      lives = kGameLivesCount;
      level = 1;
      score = 0;
   }
	return self;
}

- (void)dealloc
{	
	[super dealloc];
}

// http://www.mikeash.com/pyblog/friday-qa-2010-08-12-implementing-nscoding.html

- (void)encodeWithCoder:(NSCoder *)coder
{
   [coder encodeInteger:lives forKey:@"lives"];
   [coder encodeInteger:level forKey:@"level"];
   [coder encodeInteger:score forKey:@"score"];
   [coder encodeInteger:levelBalls forKey:@"levelBalls"];
   //[coder encodeInteger:levelBallsInPlay forKey:@"levelBallsInPlay"];
   [coder encodeInteger:levelScore forKey:@"levelScore"];
   [coder encodeInteger:levelShots forKey:@"levelShots"];
   [coder encodeInteger:levelAccurateShots forKey:@"levelAccurateShots"];
   [coder encodeInteger:levelMaxMultiplier forKey:@"levelMaxMultiplier"];
   [coder encodeInteger:shotMultiplier forKey:@"shotMultiplier"];
   [coder encodeInteger:achievementAllBalls forKey:@"achievementAllBalls"];
   [coder encodeInteger:achievementAllLives forKey:@"achievementAllLives"];
   [coder encodeInteger:achievementSkillz forKey:@"achievementSkillz"];
   [coder encodeInteger:achievement3Ballz forKey:@"achievement3Ballz"];
   [coder encodeInteger:achievement5Ballz forKey:@"achievement5Ballz"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
   [self init];

   lives = [decoder decodeIntegerForKey:@"lives"];
   level = [decoder decodeIntegerForKey:@"level"];
   score = [decoder decodeIntegerForKey:@"score"];
   levelBalls = [decoder decodeIntegerForKey:@"levelBalls"];
   //levelBallsInPlay = [decoder decodeIntegerForKey:@"levelBallsInPlay"];
   levelScore = [decoder decodeIntegerForKey:@"levelScore"];
   levelShots = [decoder decodeIntegerForKey:@"levelShots"];
   levelAccurateShots = [decoder decodeIntegerForKey:@"levelAccurateShots"];
   levelMaxMultiplier = [decoder decodeIntegerForKey:@"levelMaxMultiplier"];
   shotMultiplier = [decoder decodeIntegerForKey:@"shotMultiplier"];
   achievementAllBalls = [decoder decodeIntegerForKey:@"achievementAllBalls"];
   achievementAllLives = [decoder decodeIntegerForKey:@"achievementAllLives"];
   achievementSkillz = [decoder decodeIntegerForKey:@"achievementSkillz"];
   achievement3Ballz = [decoder decodeIntegerForKey:@"achievement3Ballz"];
   achievement5Ballz = [decoder decodeIntegerForKey:@"achievement5Ballz"];

   return self;
}

#pragma mark -
#pragma mark Scene support

- (NSString *)currentLevelFileName
{
   if (isTutorial)
      return @"tutorial.svg";
   
   NSString *name = [NSString stringWithFormat:@"level001%03d.svg", level];
   return name;
}

- (NSString *)currentArenaFileName
{
   if (isTutorial)
      return @"arena0015.jpg";
   
   // numbered 0001 .. kArenaFileCount
   NSInteger arenaIdx = (level % (kArenaFileCount - 1) ) + 1;
   NSString *name = [NSString stringWithFormat:@"arena%04d.jpg", arenaIdx];
   return name;
}

- (void)targetOut
{
   NSInteger ballScore = kScoreOneBallOut * shotMultiplier;
   score += ballScore;
   levelScore += ballScore;
   if (1 == shotMultiplier)
      levelAccurateShots++;
   levelMaxMultiplier = MAX(shotMultiplier, levelMaxMultiplier);
   if (shotMultiplier >= 4)
   {
      // do at end of level so as not to interrupt play
      //if (!achievement3Ballz)
         //[TWDataModel() reportAchievement:kAchievementCombo3 percent:100];
      //twlog("achieved achievement3Ballz!");
      achievement3Ballz++;
   }
   if (shotMultiplier >= 16)
   {
      // do at end of level so as not to interrupt play
     // if (!achievement5Ballz)
         //[TWDataModel() reportAchievement:kAchievementCombo5 percent:100];
      //twlog("achieved achievement5Ballz!");
      achievement5Ballz++;
   }
   shotMultiplier *= 2;
}

- (void)ballShot
{
   shotMultiplier = 1;
   levelShots++;
   //levelBallsInPlay++;
}

- (void)ballStopped
{
   //levelBallsInPlay--;
}

- (void)ballOut
{
   //levelBallsInPlay--;
   levelBalls--;
   // so note that a shot straight out will be two off accuracy
   levelAccurateShots--;
}

- (void)levelBegin
{
   levelBalls = kLifeBallsCount;
   //levelBallsInPlay = 0;
   levelScore = 0;
   levelShots = 0;
   levelAccurateShots = 0;
   levelMaxMultiplier = 1;
   shotMultiplier = 1;
}

- (void)levelLost
{
   [self reportInLevelAchievements];

   lives--;
   [self saveState:YES];
   
   if (self.isGameLost && !isTutorial)
      [TWDataModel() reportScore:score];
}

- (void)levelWon
{
   score += self.levelBonus;
   
   if (!isTutorial)
   {
      [self reportInLevelAchievements];
      if (kLifeBallsCount <= levelBalls)
      {
         achievementAllBalls++;
         if (10 == achievementAllBalls)
            [TWDataModel() reportAchievement:kAchievementAllBalls10 percent:100];
         else if (5 == achievementAllBalls)
            [TWDataModel() reportAchievement:kAchievementAllBalls5 percent:100];
      }
      if (kGameLivesCount <= lives)
      {
         achievementAllLives++;
         if (20 == achievementAllLives)
            [TWDataModel() reportAchievement:kAchievementAllLives20 percent:100];
         else if (10 == achievementAllLives)
            [TWDataModel() reportAchievement:kAchievementAllLives10 percent:100];
      }
      if (100.f <= self.levelAccuracy)
      {
         achievementSkillz++;
         if (10 == achievementSkillz)
            [TWDataModel() reportAchievement:kAchievementPerfectSkillz10 percent:100];
         else if (5 == achievementSkillz)
            [TWDataModel() reportAchievement:kAchievementPerfectSkillz5 percent:100];
      }
   }
   
   level++;
   [self saveState:YES];
   
   if (self.isGameWon && !isTutorial)
      [TWDataModel() reportScore:score];
}

- (void)reportInLevelAchievements
{
   if (isTutorial)
      return;
   
   if (achievement3Ballz)
   {
      //twlog("level achievement3Ballz!");
      [TWDataModel() reportAchievement:kAchievementCombo3 percent:100];
   }
   if (achievement5Ballz)
   {
      //twlog("level achievement5Ballz!");
      [TWDataModel() reportAchievement:kAchievementCombo5 percent:100];
   }
}

- (NSInteger)levelAccuracy;
{
   float accuracy = (float)MAX(0, levelAccurateShots) / (float)levelShots * 100.f;
   return lrintf(accuracy);
}

- (NSInteger)levelBonus
{
   // as per Mythic Marbles, but divisor was 10000
      
   float bonus = levelScore / 2000.f;
   bonus *= self.levelAccuracy;
   bonus *= levelBalls;
   bonus *= levelMaxMultiplier;
   
   return lrintf(bonus);
}

- (NSInteger)levelTotal
{
   NSInteger total = levelScore + self.levelBonus;
   return total;
}

- (BOOL)isGameWon
{
   if (isTutorial)
      return kTutorialLevelCount < level;
   return kGameLevelCount < level;
}

- (BOOL)isGameLost
{
   return 0 >= lives;
}

- (void)saveState:(BOOL)synchronize
{
   if (isTutorial)
      return;
   
   NSData *savedState = [NSKeyedArchiver archivedDataWithRootObject:self];
   
   [[NSUserDefaults standardUserDefaults] setObject:savedState forKey:kBZPrefCurrentGame];
   if (synchronize)
      [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
