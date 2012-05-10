/*
 File: SimpleDrillDownAppDelegate.m
 Abstract: n/a
 Version: 2.7
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */

#import "SimpleDrillDownAppDelegate.h"
#import "DataController.h"
#import "SingleLessonViewController.h"
#import "LoginViewController.h"
#import "User.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "WebViewController.h"
#import "ListOfLessonsViewController.h"
#import "LessonPlanViewController.h"

NSString *kScalingModeKey	= @"scalingMode";
NSString *kControlModeKey	= @"controlMode";
NSString *kBackgroundColorKey	= @"backgroundColor";

@implementation SimpleDrillDownAppDelegate

@synthesize window
,navigationController
,rootViewController
,dataController
,play
,detailViewController
,receivedData
,state
,loginViewController
,infoButton
,footer
,loggingIn
,gotoWebOnLogin
,localControllersArray
,tabBarController
,rjCookies;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it	
    // has enough information to create the NSURLResponse
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData	
    // receivedData is declared as a method instance elsewhere
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self showConnectionError];
}

- (void)login:(NSString*)_username withPassword:(NSString*) _password loggingIn:(BOOL)_loggingIn {
    
    self.loggingIn = _loggingIn;
    
    if( ! _loggingIn ) {
        [self logout];
        [loginViewController reset];
    }
    // Send logout message to server just for sanity, but don't really care about response.
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:_username forKey:@"username"];
    [defaults setValue:_password forKey:@"password"];
    [defaults synchronize];
    
    [self loginWithStoredCredentials];
}

- (void)loginWithStoredCredentials {
    self.state = 1;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *rootURL = [defaults stringForKey:@"rootURL"];
    NSString *user_data_url = [NSString stringWithFormat:@"%@/index.php?option=com_user&view=login&tmpl=component&return=aW5kZXgucGhwP29wdGlvbj1jb21fbGVzc29uJmZvcm1hdD1yYXc=", rootURL];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    [self createASIRequest:user_data_url];
}

- (void)downloadUserInfo {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *rootURL = [defaults stringForKey:@"rootURL"];
    NSString *user_data_url = [NSString stringWithFormat:@"%@/index.php?option=com_lesson&format=raw", rootURL];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    [self createASIRequest:user_data_url];
}

- (NSString*) getAttributeValue:(NSString*)s withMarker:(NSString*) marker {
    NSRange r = [s rangeOfString:marker];
    NSInteger i = r.location+r.length;
    NSString* sub;
    if (r.length > 0) {
        sub =[s substringFromIndex:i];
        
        NSRange r2 = [sub rangeOfString:@"\""];
        if (r2.length > 0) {
            return [sub substringToIndex:r2.location];
        }
    }
    return @"";
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
    if( receivedData == nil )
    {
        return; // shoudn't happen
    }
    
    if ([self handleData:receivedData]) {
        [connection release];
    }
    [receivedData release];
}

- (Boolean)handleData:(NSData *)data {        
    
    NSString* sData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    //    NSString *sData = [[sData1
    // stringByReplacingOccurrencesOfString:@"+" withString:@" "]
    // stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    bool ret = false;
    NSLog( @"received data '%@'", sData );
    if ( state == 1 ) {
        
        //check if logged in or logged out
        
        //base64 encoding of 'index.php?option=com_iphone&format=raw'
        //for isaacezer.com server tested.
        //NSString* urlRedirect = @"aW5kZXgucGhwP29wdGlvbj1jb21faXBob25lJmZvcm1hdD1yYXc=";
        // for rj
        NSString* urlRedirect = @"aW5kZXgucGhwP29wdGlvbj1jb21fbGVzc29uJmZvcm1hdD1yYXc=";
        
        NSString* taskString = [self getAttributeValue:sData withMarker:@"\"hidden\" name=\"task\" value=\""];
        
        NSString* task;
        if( loggingIn && [taskString isEqualToString:@"logout"] ) {
            //weird state, iphone thinks we're logging in but server
            //thinks we're already in. should never get here.
            //send another login message anyway.
            task = @"login";
        } else if( !loggingIn && [taskString isEqualToString:@"login"] ) {
            [self logout];
            state = 0;
            [loginViewController reset];
            return true;
        } else {  
            task = loggingIn ? @"login" : @"logout";
        }
        
        //NSRange r = [sData rangeOfString:urlRedirect];
        NSRange r = [sData rangeOfString:@"return\" value=\""];
        
        NSString* randomSessonId;
        if( r.length > 0) {
            NSInteger i = r.location + r.length;
            NSString* sub =[sData substringFromIndex:i];
            randomSessonId = [self getAttributeValue:sub withMarker:@"\"hidden\" name=\""];
        } else {
            randomSessonId = @"";
        }
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        
        NSString *username = [defaults stringForKey:@"username"];
        NSString *password = [defaults stringForKey:@"password"];
        NSString *rootURL = [defaults stringForKey:@"rootURL"];
        NSString *reqURL = [NSString stringWithFormat:@"%@/index.php?option=com_user", rootURL];
        NSURL *url = [NSURL URLWithString:reqURL];
        
        NSString *post = [NSString stringWithFormat:@"username=%@&passwd=%@&submit=Login&option=com_user&task=%@&return=%@&%@=1",username, password, task, urlRedirect, randomSessonId];
        
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        NSLog(@"Post data:%@", post);
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
        [request addRequestHeader:@"Accept-Charset" value:@"ISO-8859-1,utf-8;q=0.7,*;q=0.3"];
        [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate,sdch"];
        [request addRequestHeader:@"Accept-Language" value:@"en-US,en;q=0.8"];
        [request addRequestHeader:@"Cache-Control" value:@"max-age=0"];
        [request addRequestHeader:@"Connection" value:@"keep-alive"];
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        
        if ([rjCookies count] > 0) {
            [request addRequestHeader:@"Content-Length" value:postLength];
            NSHTTPCookie *c = [rjCookies objectAtIndex:0];
            [request addRequestHeader:@"Cookie" value:[NSString stringWithFormat:@"%@=%@", [c name], [c value]]];
        }
        [request addRequestHeader:@"Host" value:@"www.rhythmjuice.com"];
        [request addRequestHeader:@"Origin" value:@"https://www.rhythmjuice.com"];
        
        NSString *refURL = [NSString stringWithFormat:@"%@/index.php?option=com_user&view=login&tmpl=component&return=aW5kZXgucGhwP29wdGlvbj1jb21fbGVzc29uJmZvcm1hdD1yYXc=", rootURL];
        [request addRequestHeader:@"Referer" value:refURL];
        [request addRequestHeader:@"User-Agent" value:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_2) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11"];
        
        [request appendPostData:postData];
        
        /*
         [request setPostValue:username forKey:@"username"];
         [request setPostValue:password forKey:@"passwd"];
         [request setPostValue:@"Login" forKey:@"submit"];
         [request setPostValue:@"com_user" forKey:@"option"];
         [request setPostValue:task forKey:@"task"];
         [request setPostValue:urlRedirect forKey:@"return"];
         [request setPostValue:@"1" forKey:randomSessonId];
         */
        [request setTimeOutSeconds:20];
        [request setUseCookiePersistence:YES];
        [request setUseKeychainPersistence:YES];
        [request setUseSessionPersistence:YES];
        [request setShouldAttemptPersistentConnection:YES];
        [request setRequestCookies:rjCookies];
        [request setValidatesSecureCertificate:NO];
        
        NSMutableArray* a = [request requestCookies];
        for (int i = 0; i < [a count]; i++) {
            NSHTTPCookie* c = [a objectAtIndex:i];
            NSLog(@"cookie %@ = %@", [c name], [c value]);
        }
        
        NSLog(@"%@", [request haveBuiltRequestHeaders]);
        
        ret = true;
        
        self.state = 2; 
        
        [request setDelegate:self];
        NSLog(@"Request  HEADERS: %@", [request requestHeaders]);
        
        [request startAsynchronous];
        NSLog(@"Request  HEADERS: %@", [request requestHeaders]);
        //       [self getRequest:url withRequest:request];
        //      [request release];    
        
    } else { // state > 1
        
        if( ! self.loggingIn ) {
            state = 0;
            return ret;
        }
        
        NSString *error;
        NSDictionary *rjUserData = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:nil errorDescription:&error];
        
        if ( error != nil ) {
            NSLog(@"Error with plist file %@", error);
            [error release];
        }
        
        [self loadAppWithRJUserData:rjUserData saveToFile:true];
        [loginViewController reset];
        
        BOOL authd = dataController.user.authenticated;
        if (loggingIn && authd) {
            if (gotoWebOnLogin) {
                gotoWebOnLogin = false;
                //[self web];
            } else {
                // [window addSubview:[navigationController view]];
                [self setUpTabViews];
            }
            state = 0;
        } else if (loggingIn && !authd) {
            
            if( state == 1 ) {
                // Might have failed because we already logged in through web interface
                // so try 1 direct connection
                // TODO might be a better way like check we receive a cookie, or notice that
                // we recieve a huge HTML file when logging in.
                state = 2;
                [self downloadUserInfo];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Auth Failed" message:@"Incorrect user name or password."
                                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];
                state = 0;
            }
            
        } // logging out
    }
    
    return ret;
}

- (BOOL)loadAppWithRJUserData:(NSDictionary *)rjUserData saveToFile:(Boolean)save_to_file
{	
    // Create the data controller.
    
    Boolean retVal = false;
    
    if (self.dataController == nil) {
        DataController *d = [[DataController alloc] init];
        retVal = [d createDataFromRequest:rjUserData];
        self.dataController = d; 
        [d release];
        
        rootViewController.dataController = dataController;
        //rootViewController.lessons = dataController.user.lessons;
        
        /*
         The navigation and root view controllers are created in the main nib file.
         Configure the window with the navigation controller's view and then show it.
         */
        //   [window addSubview:[navigationController view]];
        //   [window makeKeyAndVisible];
    } else {
        // Received an update to user data;
        retVal = [self.dataController createDataFromRequest:rjUserData];
        //rootViewController.lessons = u.lessons;
        [rootViewController.tableView reloadData];
    }
    
    if (save_to_file && self.dataController.user != nil && self.dataController.user.authenticated) {
        // If we got to here the file is in good shape so save it for next time
        NSFileManager *     fileManager;
        fileManager = [NSFileManager defaultManager];
        assert(fileManager != nil);
        
        NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *rj_user_info_path = [document_folder_path stringByAppendingPathComponent:@"rj_user_info.plist"];
        
        BOOL written = [rjUserData writeToFile:rj_user_info_path atomically:NO];
        if (written)
            NSLog(@"Saved to file: %@", rj_user_info_path);
        
        dataController.gotLatestSettings = true;
    }
    
    //[self cleanDiskOfUneededVideos]; // @TODO Make run in background
    
    return retVal;
}

- (void)showConnectionError {
    if (self.dataController == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"Need web access to download your Rhythm Juice Lesson list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}


-(void)addTabView:(UIViewController*)c atIndex:(NSInteger)index title:(NSString*)title image:(UIImage*)image
{
    UINavigationController *localNavigationController;
    localNavigationController = [[UINavigationController alloc] initWithRootViewController:c];
    
	UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:title image:image tag:index];	
    
    localNavigationController.tabBarItem = item;
    [item release];
    
	[localControllersArray addObject:localNavigationController];
	[localNavigationController release];
}

-(void)setUpTabViews {
    
    if( [localControllersArray count] > 2 )
        return;
    
    [localControllersArray removeAllObjects];
    
    ListOfLessonsViewController *l1 = [[ListOfLessonsViewController alloc] initWithStyle:UITableViewStylePlain];
    l1.title = NSLocalizedString(@"Lessons", @"List of My Lessons Title");
    l1.lessons = self.dataController.user.lessons;
    l1.dataController = self.dataController;
    
    UIImage* im = [UIImage imageNamed:@"status-icon-30x30.png"];
    [self addTabView:l1 atIndex:0 title:@"My Lessons" image:im];
    [l1 release];
    
    ListOfLessonsViewController *l2 = [[ListOfLessonsViewController alloc] initWithStyle:UITableViewStylePlain];
    l2.title = NSLocalizedString(@"My Playlists", @"List of My Lessons Title");
    l2.lessons = self.dataController.user.playlists;
    l2.dataController = self.dataController;
    
    [self addTabView:l2 atIndex:1 title:@"Playlists" image:[UIImage imageNamed:@"playlists-icon-30x30.png"]];
    [l2 release];
    
    LessonPlanViewController *lp;
    lp = [[LessonPlanViewController alloc] initWithStyle:UITableViewStylePlain];
    
    lp.title = NSLocalizedString(@"My Lesson Plans", @"List of My Lesson Plans Title");
    
    lp.dataController = self.dataController;
    lp.lessonPlans = self.dataController.user.lessonPlans;
    
    [self addTabView:lp atIndex:2 title:@"Plans" image:[UIImage imageNamed:@"plans-icon-30x30.png"]];
    [lp release];
    
    [self createStandardButtons];
    
    // load up our tab bar controller with the view controllers
	tabBarController.viewControllers = localControllersArray;
    
	// add the tabBarController as a subview in the window
	[window addSubview:tabBarController.view];
    
    // need this last line to display the window (and tab bar controller)
	[window makeKeyAndVisible];
    
    [self showMyLessonsTab];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	//I create my TabBar controlelr
	tabBarController = [[UITabBarController alloc] init];
    
    tabBarController.title = NSLocalizedString(@"Rhythm Juice", @"Master view navigation title");
    
    self.rjCookies = [[[NSMutableArray alloc] init] autorelease];
    
    localControllersArray = [[NSMutableArray alloc] initWithCapacity:5];
    LoginViewController *_loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:[NSBundle mainBundle]];
    _loginViewController.delegate = self;
    
    self.loginViewController = _loginViewController;
    
    [self createStandardButtons];
    
    // set up the table's footer view based on our UIView 'myFooterView' outlet
	CGRect newFrame = CGRectMake(0.0, 0.0, self.rootViewController.tableView.bounds.size.width, self.footer.frame.size.height);
	self.footer.backgroundColor = [UIColor clearColor];
	self.footer.frame = newFrame;
	self.rootViewController.tableView.tableFooterView = self.footer;	// note this will override UITableView's 'sectionFooterHeight' property
    
    self.rootViewController.delegate = self;
    
    // load up our tab bar controller with the view controllers
	tabBarController.viewControllers = localControllersArray;
    
    tabBarController.view.opaque = NO;
    tabBarController.selectedIndex = 1;
    
    UIImageView* image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue-fullbg.png"]];
    tabBarController.navigationItem.titleView = image;
    [image autorelease];
    
    // add the tabBarController as a subview in the window
	[window addSubview:tabBarController.view];
    
    // need this last line to display the window (and tab bar controller)
	[window makeKeyAndVisible];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"rootURL"];
    if (testValue == nil)
    {
        [defaults setValue:@"http://www.rhythmjuice.com/rhythmjuice" forKey:@"rootURL"];
        [defaults synchronize];
    }
    
    // Check if we already have user storage saved
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *rj_user_info_path = [document_folder_path stringByAppendingPathComponent:@"rj_user_info.plist"];
    
    NSLog(@"%@", rj_user_info_path);
    if ( [fileManager fileExistsAtPath:rj_user_info_path]) {
        NSDictionary* data = [[NSDictionary alloc] initWithContentsOfFile:rj_user_info_path];
        [self loadAppWithRJUserData:data saveToFile:false];
        [data release];
        [loginViewController update];
        [self setUpTabViews];
        
        [self refresh:true];
    } else {
        // [window addSubview:[loginViewController view]];
    }
    
    // Regardless of whether or not we saved the users's info,
    // try to request an updated version from the server.
    // NSString* user_data_url = @"http://rj.isaacezer.com/index.php?option=com_user&view=login&tmpl=component";
    //NSString* user_data_url = @"http://rj.isaacezer.com/index.php?option=com_iphone&format=raw";
    
    
    //NSString* user_data_url = @"http://localhost/rj/userdata.plist";
    
    //aW5kZXgucGhwP29wdGlvbj1jb21faXBob25lJmZvcm1hdD1yYXc - base64 encoding of 'index.php?option=com_iphone&format=raw'
    
    // [self cleanDiskOfUneededVideos]; // @TODO Make run in background
}

- (IBAction)loginButtonAction:(id)sender {    
    if (sender == self.infoButton) {
        [window addSubview:[loginViewController view]];
        [loginViewController update];
    } else { // login view
        [window addSubview:[rootViewController view]];
    }
}

- (void) createStandardButtons {
    [self addTabView:[self webView] atIndex:0 title:@"Online" image:[UIImage imageNamed:@"online-icon-30x30.png"]];
    
    [self addTabView:self.loginViewController atIndex:1 title:@"Info" image:[UIImage imageNamed:@"logout-icon-30x30.png"]];
}

- (void) logout {
    [localControllersArray removeAllObjects];
    [self createStandardButtons];
    tabBarController.viewControllers = localControllersArray;
    tabBarController.selectedIndex = 1;
    
    [window makeKeyAndVisible];
    
    if( dataController.user != nil ) {
        [dataController.user logout];
    }
    
    // Check if we already have user storage saved
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *rj_user_info_path = [document_folder_path stringByAppendingPathComponent:@"rj_user_info.plist"];
    
    if ( [fileManager fileExistsAtPath:rj_user_info_path]) {
        NSError* error;
        [fileManager removeItemAtPath:rj_user_info_path error:&error];
    }
    
    NSString *localFileManager = [document_folder_path stringByAppendingPathComponent:@"videos"]; 
    
    NSError *error;
    [fileManager removeItemAtPath:localFileManager error:&error];
}


- (void)cleanDiskOfUneededVideos {
    return; // Don't need this right now.
    
    NSMutableSet * validLessonsNames = [NSMutableSet set];
    for (int i = 0; i < [[[dataController user] lessons] count]; i++) {
        NSString* name = [[[[dataController user] lessons] objectAtIndex:i] title];
        NSLog(@"Valid Lesson Name %@", name);
        [validLessonsNames addObject:name];
    }
    
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *localFileManager = [document_folder_path stringByAppendingPathComponent:@"lessons"]; 
    
    NSDirectoryEnumerator *dirEnum =
    [fileManager enumeratorAtPath:localFileManager];
    
    NSString *file;
    while (file = [dirEnum nextObject]) {
        NSLog(@"Checking file %@", file);
        if ( [validLessonsNames containsObject:file] ) {
            [[[dataController user] getLesson:file] cleanupDirectory];
        } else {
            NSError *error;
            [fileManager removeItemAtPath:file error:&error];
        }
    }
}

- (void)createASIRequest:(NSString*)path {
    NSLog(@"ASI Request URL: %@", path);
    NSURL* chapter_remote_url = [NSURL URLWithString:path];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:chapter_remote_url];
    [request setUseCookiePersistence:YES];
    [request setValidatesSecureCertificate:NO];
    
    [request setRequestCookies:rjCookies];
    
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    
    NSLog(@"STATUS CODE: %i", [request responseStatusCode]);
    NSLog(@"STATUS MESSAGE: %@", [request responseStatusMessage]);
    NSLog(@"Request  HEADERS: %@", [request requestHeaders]);
    NSLog(@"RESPONSE HEADERS: %@", [request responseHeaders]);
    
    NSArray* a = [request responseCookies];
    if ([a count] > 0) {
        [[self rjCookies] removeAllObjects];
        [[self rjCookies] addObjectsFromArray:a];
        for (int i = 0; i < [a count]; i++) {
            NSHTTPCookie* c = [a objectAtIndex:i];
            NSLog(@"cookie %@ = %@", [c name], [c value]);
        }
    }
    
    [self handleData:responseData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Error = %@", error);
}


- (void)dealloc {
    [navigationController release];
	[rootViewController release];
    [window release];
    [dataController release];
	[play release];
    [receivedData release];
    [loginViewController release];
    [footer release];
    [infoButton release];
    [rjCookies release];
    [super dealloc];
}

- (void) refresh:(BOOL)gotoWeb {
    gotoWebOnLogin = gotoWeb;
    loggingIn = true;
    [self loginWithStoredCredentials];
}

- (WebViewController*) webView {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *rootURL = [defaults stringForKey:@"rootURL"];
    
    WebViewController *webController;
	webController = [[[WebViewController alloc] initWithURLPassed:rootURL withDelegate:self] autorelease];
    webController.title = NSLocalizedString(@"RJ on the Web", @"Browser Title");
    
    return webController;
}

- (void) showMyLessonsTab {
    tabBarController.selectedIndex = 0;
}

- (void) showWebTab {
    tabBarController.selectedIndex = 0; 
}

@end
