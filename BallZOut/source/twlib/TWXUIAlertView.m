//
//  TWXUIAlertView.m
//
//  Copyright 2009 Trollwerks Inc. All rights reserved.
//

#import "TWXUIAlertView.h"

@implementation UIAlertView (TWXUIAlertView)

+ (UIAlertView *)twxUnimplementedAlert
{
   UIAlertView *alert = [UIAlertView
      twxOKAlert:@"UNDERCONSTRUCTION"
      withMessage:@"NOTIMPLEMENTEDYET"
   ];
   return alert;
}

+ (UIAlertView *)twxOKAlert:(NSString *)title withMessage:(NSString *)message
{
   UIAlertView *alert = [[[UIAlertView alloc] 
      initWithTitle:NSLocalizedString(title, nil) 
      message:NSLocalizedString(message, nil) 
      delegate:nil 
      cancelButtonTitle:nil 
      otherButtonTitles:NSLocalizedString(@"OK", nil),
                        nil
   ] autorelease];
   [alert show];
   
   return alert;
}

+ (UIAlertView *)twxOKCancelAlert:(NSString *)title withMessage:(NSString *)message
{
   UIAlertView *alert = [[[UIAlertView alloc] 
                          initWithTitle:NSLocalizedString(title, nil) 
                          message:NSLocalizedString(message, nil) 
                          delegate:nil 
                          cancelButtonTitle:NSLocalizedString(@"CANCEL", nil) 
                          otherButtonTitles:NSLocalizedString(@"OK", nil),
                          nil
                          ] autorelease];
   [alert show];
   
   return alert;
}

@end
