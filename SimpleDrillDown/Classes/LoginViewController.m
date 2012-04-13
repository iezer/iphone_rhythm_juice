//
//  LoginViewController.m
//  LoginApp
//
//  Created by Chris Riccomini on 12/5/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "DataController.h"
#import "User.h"

@implementation LoginViewController

@synthesize usernameField, passwordField, loginButton, refreshButton, forgotPasswordButton, cancelButton, loginIndicator, delegate;

/*
// Override initWithNibName:bundle: to load the view using a nib file then perform additional customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [self update];
    cancelButton.hidden = TRUE;
    [super viewDidLoad];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [super dealloc];
}

- (IBAction) showWebView:(id)sender
{
    [delegate showWebTab];
}

- (IBAction) login: (id) sender
{
	loginIndicator.hidden = FALSE;
	[loginIndicator startAnimating];
    cancelButton.hidden = FALSE;
	loginButton.enabled = FALSE;
    
    [usernameField resignFirstResponder];
    [passwordField resignFirstResponder];
    
    User* u = delegate.dataController.user;
    BOOL loggedIn = u != nil && u.authenticated;

    [delegate login:usernameField.text withPassword:passwordField.text loggingIn:!loggedIn];
}

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder]; 
    return YES;
}

-(BOOL) loggedIn {
    User* u = delegate.dataController.user;
    return u != nil && u.authenticated;
}

-(void) update {
    User* u = delegate.dataController.user;
    
    NSString* t;
    if ([self loggedIn]) {
        usernameField.text = u.username;
        t = @"Logout";
        refreshButton.enabled = TRUE;
        [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
        forgotPasswordButton.hidden = true;
    } else {
        t = @"Login";
        refreshButton.enabled = TRUE;
        [refreshButton setTitle:@"Join Now" forState:UIControlStateNormal];
        forgotPasswordButton.hidden = false;
    }
    [loginButton setTitle:t forState:UIControlStateNormal];
    self.title = NSLocalizedString(t, t); 
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* uname = [defaults stringForKey:@"username"];
    NSString* p = [defaults stringForKey:@"password"];
    if (uname != nil) {
        [usernameField setText:uname];
    }
    if (p != nil) {
        [passwordField setText:p];
    }
}

-(void) cancelIndicators {
    loginIndicator.hidden = TRUE;
	[loginIndicator stopAnimating];
	loginButton.enabled = TRUE;
    cancelButton.hidden = TRUE;
    
}

-(void) reset {
    [self cancelIndicators];
    [self update];
}

- (IBAction) cancel: (id) sender {
    [self cancelIndicators];
}

- (IBAction) refresh: (id) sender
{
	if( [self loggedIn] ) {
    loginIndicator.hidden = FALSE;
	[loginIndicator startAnimating];
    cancelButton.hidden = FALSE;
	loginButton.enabled = FALSE;
    
    delegate.loggingIn = true;
    [delegate loginWithStoredCredentials];
    } else {
        [delegate showWebTab];
    }
}
@end
