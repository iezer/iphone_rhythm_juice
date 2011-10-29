//
//  LoginAppAppDelegate.h
//  LoginApp
//
//  Created by Chris Riccomini on 12/5/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@interface LoginAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	LoginViewController *loginViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) LoginViewController *loginViewController;

@end

