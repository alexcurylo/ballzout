//
//  TWC2HighScoresNode.h
//  Sapus Tongue
//
//  Created by Ricardo Quesada on 18/09/08.
//  Copyright 2008 Sapus Media. All rights reserved.
//

#import "cocos2d.h"
/*
#import <UIKit/UIKit.h>
//#import "GlobalScore.h"
*/

@interface TWC2HighScoresNode : Layer /*<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>*/
{
/*
 UITableView *myTableView;
	
	UIActivityIndicatorView *activityIndicator;
*/
	BOOL displayLocalScores;
}

+(id) sceneWithPlayAgain: (BOOL) again;
-(id) initWithPlayAgain: (BOOL) again;

@end
