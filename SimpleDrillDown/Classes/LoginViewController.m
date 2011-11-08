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

@synthesize usernameField;
@synthesize passwordField;
@synthesize loginButton;
@synthesize infoButton;
@synthesize loginIndicator;
@synthesize delegate;

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

/*
// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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

- (IBAction) login: (id) sender
{
	
	loginIndicator.hidden = FALSE;
	[loginIndicator startAnimating];
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
    
    if (u != nil && u.authenticated) {
        usernameField.text = u.username;
        [loginButton setTitle:@"Logout" forState:UIControlStateNormal];
    } else {
        [loginButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}
-(void) reset {
    loginIndicator.hidden = TRUE;
	[loginIndicator stopAnimating];
	loginButton.enabled = TRUE;
}

@end
