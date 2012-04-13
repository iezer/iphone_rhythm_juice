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
    IBOutlet UIButton *refreshButton;
    IBOutlet UIButton *forgotPasswordButton;
    IBOutlet UIButton *cancelButton;
	IBOutlet UIActivityIndicatorView *loginIndicator;
    SimpleDrillDownAppDelegate *delegate; 
}

@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIButton *refreshButton;
@property (nonatomic, retain) UIButton *forgotPasswordButton;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIActivityIndicatorView *loginIndicator;
@property (nonatomic, retain) SimpleDrillDownAppDelegate *delegate;

- (IBAction) login: (id) sender;
- (IBAction) refresh: (id) sender;
- (IBAction) showWebView:(id)sender;
- (IBAction) cancel:(id)sender;
-(BOOL) textFieldShouldReturn:(UITextField*) textField;
-(void) reset;
-(void) update;


@end
