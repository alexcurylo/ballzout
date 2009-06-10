//
//  TWC2HighScoresNode.m
//  Sapus Tongue
//
//  Created by Ricardo Quesada on 18/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//

//
// Code that shows the "high score" scene
//   * display world wide scores
//   * display scores by country
//   * display local scores
//
//  uses cocoslive to obtain the scores

#import "TWC2HighScoresNode.h"
#import "TWC2MainMenuNode.h"
#import "TWC2GameNode.h"
#import "TWC2SoundMenuItem.h"
#import "TWC2GradientLayer.h"
#import "chipmunk.h"
/*
 #import "cocoslive.h"
#import "SapusTongueAppDelegate.h"
#import "LocalScore.h"
#import "GameNode.h"
*/

#define kCellHeight (30)
#define kMaxScoresToFetch (50)

@interface TWC2HighScoresNode (Private)
-(UITableView*) newTableView;
-(void) initGradient;
@end

@implementation TWC2HighScoresNode
+(id) sceneWithPlayAgain: (BOOL) again {
	Scene *s = [Scene node];
	id node = [[TWC2HighScoresNode alloc] initWithPlayAgain:again];
	[s addChild:node];
	[node release];
	return s;
}

-(id) initWithPlayAgain: (BOOL) again {
	if( ![super init] )
		return nil;
	
	Sprite *back = [Sprite spriteWithFile:@"TWC2HighScoresBackground.png"];
	back.transformAnchor = cpvzero;
	[self addChild:back];

	Menu *menuH = nil;
	MenuItem* menuItem = [TWC2SoundMenuItem itemFromNormalImage:@"btn-menumed-normal.png" selectedImage:@"btn-menumed-selected.png" target:self selector:@selector(menuCB:)];
	
	/*
    Menu *menuV = nil;
	MenuItem *worldScores = [TWC2SoundMenuItem itemFromNormalImage:@"btn-world-normal.png" selectedImage:@"btn-world-selected.png" target:self selector:@selector(globalScoresCB:)];
	MenuItem *countryScores = [TWC2SoundMenuItem itemFromNormalImage:@"btn-country-normal.png" selectedImage:@"btn-country-selected.png" target:self selector:@selector(countryScoresCB:)];
	MenuItem *myScores = [TWC2SoundMenuItem itemFromNormalImage:@"btn-my_scores-normal.png" selectedImage:@"btn-my_scores-selected.png" target:self selector:@selector(localScoresCB:)];

	menuV = [Menu menuWithItems: worldScores, countryScores, myScores, nil];
	[menuV alignItemsVertically];
	menuV.position = cpv(432,200);
    */

	// Menu
	if( ! again ) {
		menuH = [Menu menuWithItems: menuItem, nil];
	}
	else {
		MenuItem* itemAgain = [TWC2SoundMenuItem itemFromNormalImage:@"btn-playagain-normal.png" selectedImage:@"btn-playagain-selected.png" target:self selector:@selector(playAgainCB:)];
		menuH = [Menu menuWithItems: itemAgain, menuItem, nil];
	}
	
	[menuH alignItemsHorizontally];
	if( ! again )
		menuH.position = cpv(420,17);
	else
		menuH.position = cpv(360,17);


	[self addChild: menuH z:0];
	/*
    [self addChild: menuV z:0];
   */

	[self initGradient];

	// local Scores
	displayLocalScores = YES;
	
	[self schedule:@selector(delayStart:) interval:1.0f];

	return self;
}

-(void) initGradient {
	// back color
	TWC2GradientLayer *g = [TWC2GradientLayer layerWithColor:0];
	[g setBottomColor:0xb3e2e6ff topColor:0x93c2c6ff];
	[g changeHeight:320];
	[g changeWidth:480];
	[self addChild: g z:-10];	
}

- (void)dealloc
{
   /*
	[activityIndicator release];
	[myTableView release];
*/
	[super dealloc];
}

//
// TIP:
// The heavy part of init and the UIKit controls are initialized after the transition is finished.
// This trick is used to:
//    * create a smooth transition (load heavy resources after the transition is finished)
//    * show UIKit controls after the transition to simulate that they transition like any other control
//
-(void) delayStart: (ccTime) dt
{
   (void)dt;
   
	[self unschedule:_cmd];
   
   /*
	// activity indicator
	if( ! activityIndicator ) {
		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
		activityIndicator.frame = CGRectMake(280, 440, 20, 20);
		[[[Director sharedDirector] openGLView] addSubview:activityIndicator];
		activityIndicator.hidesWhenStopped = YES;
		activityIndicator.opaque = YES;
	}
	
	// table
	if( !myTableView )
		myTableView = [self newTableView];
	[[[Director sharedDirector] openGLView] addSubview: myTableView];
    */
}

// menu callbacks

/*
 -(void) globalScoresCB: (id) sender
{	
	ScoreServerRequest *request = [[ScoreServerRequest alloc] initWithGameName:@"Sapus Tongue" delegate:self];
	if( [request requestScores:kQueryAllTime limit:kMaxScoresToFetch offset:0 flags:kQueryFlagIgnore] )
		[activityIndicator startAnimating];
	[request release];
}
*/

/*
-(void) countryScoresCB: (id) sender
{	
	ScoreServerRequest *request = [[ScoreServerRequest alloc] initWithGameName:@"Sapus Tongue" delegate:self];
	if( [request requestScores:kQueryAllTime limit:kMaxScoresToFetch offset:0 flags:kQueryFlagByCountry] )
		[activityIndicator startAnimating];
	[request release];
}
*/

/*
-(void) localScoresCB: (id) sender
{	
	displayLocalScores = YES;
	[myTableView reloadData];
}
*/
 
-(void) menuCB:(id) sender
{
   (void)sender;
/*
 if( activityIndicator ) {
		[activityIndicator removeFromSuperview];
		[activityIndicator release];
		activityIndicator = nil;
	}

	if( myTableView ) {
		[myTableView removeFromSuperview];
		[myTableView release];
		myTableView = nil;
	}
*/
	[[Director sharedDirector] replaceScene: [SplitRowsTransition transitionWithDuration:1.0f scene: [TWC2MainMenuNode scene]]];
}

-(void) playAgainCB:(id) sender
{
   (void)sender;
/*
 if( activityIndicator ) {
		[activityIndicator removeFromSuperview];
		[activityIndicator release];
		activityIndicator = nil;
	}
	
	if( myTableView ) {
		[myTableView removeFromSuperview];
		[myTableView release];
		myTableView = nil;
	}
*/
	[[Director sharedDirector] replaceScene: [FadeTransition transitionWithDuration:1.0f scene: [TWC2GameNode scene]]];
}

/*
 // table view
-(UITableView*) newTableView {
	UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
	tv.delegate = self;
	tv.dataSource = self;
	
	tv.opaque = YES;
	
	tv.transform = CGAffineTransformMakeRotation((float)M_PI / 2.0f); // 180 degrees
#define Xoffset 6
#define Yoffset 40
	tv.frame = CGRectMake(Yoffset, Xoffset, 210, 380);
	return tv;
}
*/

#pragma mark GlobalScore Delegate

/*
-(void) scoreRequestOk: (id) sender {
	displayLocalScores = NO;
	
	SapusTongueAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	// scores shall is autoreleased... I guess
	NSArray *scores = [sender parseScores];
	
	NSMutableArray *mutable = [NSMutableArray arrayWithArray:scores];
	appDelegate.globalScores = mutable;
	
	[activityIndicator stopAnimating];
	[myTableView reloadData];	
}
*/

/*
-(void) scoreRequestFail: (id) sender {
   (void)sender;

	[activityIndicator stopAnimating];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection failed"
														message:@"Make sure that you have an active cellular or WiFi connection."
														delegate:self
														cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];	
}
*/

#pragma mark UITableView Delegate

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	SapusTongueAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	if( displayLocalScores )
		return [[appDelegate scores] count];
	else
		return [[appDelegate globalScores] count];
}

-(void) setImage:(UIImage*)image inTableViewCell:(UITableViewCell*)cell
{
#ifndef __IPHONE_3_0
	cell.image = image;	
#else	
	cell.imageView.image = image;
#endif
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"HighScoreCell";
	
	UILabel *name, *score, *idx, *speed, *angle;
	UIView *view;
	UIImageView *imageView;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
		cell.opaque = YES;

		// Position
		idx = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24, kCellHeight-2)];
		idx.tag = 3;
		//		name.font = [UIFont boldSystemFontOfSize:16.0f];
		idx.font = [UIFont fontWithName:@"Marker Felt" size:16.0f];
		idx.adjustsFontSizeToFitWidth = YES;
		idx.textAlignment = UITextAlignmentRight;
		idx.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
		idx.autoresizingMask = UIViewAutoresizingFlexibleRightMargin; 
		[cell.contentView addSubview:idx];
		[idx release];
		
		// Name
		name = [[UILabel alloc] initWithFrame:CGRectMake(65.0f, 0.0f, 150, kCellHeight-2)];
		name.tag = 1;
//		name.font = [UIFont boldSystemFontOfSize:16.0];
		name.font = [UIFont fontWithName:@"Marker Felt" size:16.0f];
		name.adjustsFontSizeToFitWidth = YES;
		name.textAlignment = UITextAlignmentLeft;
		name.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
		name.autoresizingMask = UIViewAutoresizingFlexibleRightMargin; 
		[cell.contentView addSubview:name];
		[name release];
		
		// Score
		score = [[UILabel alloc] initWithFrame:CGRectMake(200, 0.0f, 70.0f, kCellHeight-2)];
		score.tag = 2;
		score.font = [UIFont systemFontOfSize:16.0f];
		score.textColor = [UIColor darkGrayColor];
		score.adjustsFontSizeToFitWidth = YES;
		score.textAlignment = UITextAlignmentRight;
		score.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[cell.contentView addSubview:score];
		[score release];

		// Speed
		speed = [[UILabel alloc] initWithFrame:CGRectMake(275, 0.0f, 40.0f, kCellHeight-2)];
		speed.tag = 5;
		speed.font = [UIFont systemFontOfSize:16.0f];
		speed.textColor = [UIColor darkGrayColor];
		speed.adjustsFontSizeToFitWidth = YES;
		speed.textAlignment = UITextAlignmentRight;
		speed.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[cell.contentView addSubview:speed];
		[speed release];
		
		// Angle
		angle = [[UILabel alloc] initWithFrame:CGRectMake(315, 0.0f, 35.0f, kCellHeight-2)];
		angle.tag = 6;
		angle.font = [UIFont systemFontOfSize:16.0f];
		angle.textColor = [UIColor darkGrayColor];
		angle.adjustsFontSizeToFitWidth = YES;
		angle.textAlignment = UITextAlignmentRight;
		angle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[cell.contentView addSubview:angle];
		[angle release];
				
		// Flag
		view = [[UIImageView alloc] initWithFrame:CGRectMake(360, 10.0f, 16, kCellHeight-2)];
		view.opaque = YES;
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fam.png"]];
		imageView.opaque = YES;
		imageView.tag = 1;
		[view addSubview:imageView];
		[cell.contentView addSubview:view];		
		view.tag = 4;
		[view release];
		[imageView release];
		
	} else {
		name = (UILabel *)[cell.contentView viewWithTag:1];
		score = (UILabel *)[cell.contentView viewWithTag:2];
		idx = (UILabel *)[cell.contentView viewWithTag:3];
		view = (UIView*)[cell.contentView viewWithTag:4];
		imageView = (UIImageView*)[view viewWithTag:1];
		speed = (UILabel *)[cell.contentView viewWithTag:5];
		angle = (UILabel *)[cell.contentView viewWithTag:6];

	}
	
	int i = indexPath.row;
	SapusTongueAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

	idx.text = [NSString stringWithFormat:@"%d", indexPath.row + 1];

	if(displayLocalScores) {
		
		LocalScore *s = [[appDelegate scores] objectAtIndex: i];
		name.text = s.playername;
		score.text = [s.score stringValue];
		speed.text = [s.speed stringValue];
		angle.text = [s.angle stringValue];

		if( [s.playerType intValue] == 1 )
			[self setImage:[UIImage imageNamed:@"MonusHead.png"] inTableViewCell:cell];
		else
			[self setImage:[UIImage imageNamed:@"SapusHead.png"] inTableViewCell:cell];

		imageView.image = nil;	
	} else {
		NSDictionary *s = [[appDelegate globalScores] objectAtIndex:i];
		name.text = [s objectForKey:@"usr_playername"];
		// this is an NSNumber... convert it to string
		score.text = [[s objectForKey:@"cc_score"] stringValue];
		speed.text = [[s objectForKey:@"usr_speed"] stringValue];
		angle.text = [[s objectForKey:@"usr_angle"] stringValue];

		NSNumber *type = [s objectForKey:@"usr_playertype"];
		if( [type intValue] == 1 )
			[self setImage:[UIImage imageNamed:@"MonusHead.png"] inTableViewCell:cell];

		else
			[self setImage:[UIImage imageNamed:@"SapusHead.png"] inTableViewCell:cell];
		
		NSString *flag = [[s objectForKey:@"cc_country"] lowercaseString];
		UIImage *image;
		image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", flag]];
		if(! image )
			image = [UIImage imageNamed:@"fam.png"];
		imageView.image = image;		
	}
	return cell;
}
 
*/

#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   (void)alertView;
   (void)buttonIndex;
}

@end
