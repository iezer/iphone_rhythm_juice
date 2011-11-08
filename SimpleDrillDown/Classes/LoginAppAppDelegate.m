//
//  LoginAppAppDelegate.m
//  LoginApp
//
//  Created by Chris Riccomini on 12/5/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import "LoginAppAppDelegate.h"
#import "LoginViewController.h"

@implementation LoginAppAppDelegate

@synthesize window;
@synthesize loginViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

	LoginViewController *_loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:[NSBundle mainBundle]];
	self.loginViewController = _loginViewController;
	[_loginViewController release];
	[window addSubview:[loginViewController view]];
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}

- (void)dealloc {
	[loginViewController release];
    [window release];
    [super dealloc];
}


@end
