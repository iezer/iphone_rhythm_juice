//
//  LoginViewController.h
//  LoginApp
//
//  Created by Chris Riccomini on 12/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleDrillDownAppDelegate.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
	IBOutlet UIButton *loginButton;
    IBOutlet UIButton *infoButton;
	IBOutlet UIActivityIndicatorView *loginIndicator;
    SimpleDrillDownAppDelegate *delegate; 
}

@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIButton *infoButton;
@property (nonatomic, retain) UIActivityIndicatorView *loginIndicator;
@property (nonatomic, retain) SimpleDrillDownAppDelegate *delegate;

- (IBAction) login: (id) sender;
-(BOOL) textFieldShouldReturn:(UITextField*) textField;
-(void) reset;
-(void) update;

@end
