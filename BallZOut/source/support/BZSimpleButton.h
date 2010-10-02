//
//  BZSimpleButton.h
//
//  Created by Steffen Itterheim on 27.11.09.
//  Copyright 2009 Steffen Itterheim. All rights reserved.
//

#import "cocos2d.h"

@class BZMenuItem;

static const int kButtonTag = 666;

enum
{
   kPositionTopScreenEdge = 9999,
   kPositionLeftScreenEdge = -9999,
   kPositionRightScreenEdge = 9999,
   kPositionBottomScreenEdge = -9999,
};

@interface BZSimpleButton : CCNode <CCRGBAProtocol>
{
	GLubyte opacity_;
	ccColor3B color_;

@protected
	CCMenu* menu;
   
   BZMenuItem *item_;
}

@property (readonly) CCMenu* menu;

-(void) setColor:(ccColor3B)color;
-(ccColor3B) color;
-(GLubyte) opacity;
-(void) setOpacity: (GLubyte) opacity;

+(void) setIsEnabledForAllButtons:(NSMutableArray*)children enabled:(bool)enabled;
-(void) setIsEnabled:(bool)enabled;

+(id) simpleButtonAtPosition:(CGPoint)position image:(NSString*)image target:(id)target selector:(SEL)selector;
-(id) initWithPosition:(CGPoint)position image:(NSString*)image target:(id)target selector:(SEL)selector;

- (void)startWaving;

@end
