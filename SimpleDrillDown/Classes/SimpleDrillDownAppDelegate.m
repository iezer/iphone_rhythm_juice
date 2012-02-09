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

NSString *kScalingModeKey	= @"scalingMode";
NSString *kControlModeKey	= @"controlMode";
NSString *kBackgroundColorKey	= @"backgroundColor";


@implementation SimpleDrillDownAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;
@synthesize dataController;
@synthesize play;
@synthesize detailViewController;
@synthesize receivedData;
@synthesize state;
@synthesize loginViewController;

@synthesize username;
@synthesize password;

@synthesize infoButton;
@synthesize footer;
@synthesize loggingIn;

@synthesize rjCookies;

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
    self.username = _username;
    self.password = _password;
    self.state = 1;
    self.loggingIn = _loggingIn;
    
    // for local server
    //NSString* user_data_url = @"http://rj.isaacezer.com/index.php?option=com_user&view=login&tmpl=component&return=aW5kZXgucGhwP29wdGlvbj1jb21faXBob25lJmZvcm1hdD1yYXc=";
    
    /*
    NSString* user_data_url;
    if (_loggingIn) {
        user_data_url = @"http://localhost/rj/rj-login.html";
    } else {
        user_data_url = @"http://localhost/rj/rj-logout.html";
    } */
    NSString* user_data_url = @"https://www.rhythmjuice.com/sandbox/index.php?option=com_user&view=login&tmpl=component&return=aW5kZXgucGhwP29wdGlvbj1jb21fbGVzc29uJmZvcm1hdD1yYXc=";
    http://www.rhythmjuice.com/sandbox/index.php?option=com_user&view=login&tmpl=component&return=aW5kZXgucGhwP29wdGlvbj1jb21fbGVzc29lJmZvcm1hdD1yYXc=
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    
    [self getRequest:user_data_url];
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

    NSString* sData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    [receivedData release];
    if ([self handleData:sData]) {
        [connection release];
    }
    [sData release];
}

- (Boolean)handleData:(NSString *)sData {        

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
        NSRange r = [sData rangeOfString:@"return"];
        NSInteger i = r.location + r.length;
        NSString* sub =[sData substringFromIndex:i];
        
        NSString* randomSessonId = [self getAttributeValue:sub withMarker:@"\"hidden\" name=\""];
        
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        
        NSURL *url = [NSURL URLWithString:@"https://www.rhythmjuice.com/sandbox/index.php?option=com_user"];
        
        NSString *post = [NSString stringWithFormat:@"username=%@&passwd=%@&submit=Login&option=com_user&task=%@&return=%@&%@=1",username, password, task, urlRedirect, randomSessonId];
        
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        
        [request addRequestHeader:@"Accept" value:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"];
        [request addRequestHeader:@"Accept-Charset" value:@"ISO-8859-1,utf-8;q=0.7,*;q=0.3"];
        [request addRequestHeader:@"Accept-Encoding" value:@"gzip,deflate,sdch"];
        [request addRequestHeader:@"Accept-Language" value:@"en-US,en;q=0.8"];
        [request addRequestHeader:@"Cache-Control" value:@"max-age=0"];
        [request addRequestHeader:@"Connection" value:@"keep-alive"];
        [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
        [request addRequestHeader:@"Content-Length" value:postLength];
        NSHTTPCookie *c = [rjCookies objectAtIndex:0];
        [request addRequestHeader:@"Cookie" value:[NSString stringWithFormat:@"%@=%@", [c name], [c value]]];
        [request addRequestHeader:@"Host" value:@"www.rhythmjuice.com"];
        [request addRequestHeader:@"Origin" value:@"https://www.rhythmjuice.com"];
        [request addRequestHeader:@"Referer" value:@"https://www.rhythmjuice.com/sandbox/index.php?option=com_user&view=login&tmpl=component&return=aW5kZXgucGhwP29wdGlvbj1jb21fbGVzc29uJmZvcm1hdD1yYXc="];
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
        
        NSMutableArray* a = [request requestCookies];
        for (int i = 0; i < [a count]; i++) {
            NSHTTPCookie* c = [a objectAtIndex:i];
            NSLog(@"cookie %@ = %@", [c name], [c value]);
        }
        
        NSLog(@"%@", [request haveBuiltRequestHeaders]);
        
        
    /*    

     
     //urlRedirect = @"aW5kZXgucGhw";
     //urlRedirect = @"aW5kZXgucGhwP29wdGlvbj1jb21fbGVzc29uJmZvcm1hdD1yYXc%3D";


     
     NSString* url;
        if (loggingIn) {
            url = @"http://localhost/rj/userdata.plist";
        } else { 
            url = @"http://localhost/rj/userdata-anonymous.plist";
        }
        
        //NSString* url = @"http://rj.isaacezer.com/index.php?option=com_user";

        //NSString* url = @"http://www.rhythmjuice.com/sandbox/index.php?option=com_lesson&format=raw";
        
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"POST"];
        [request setHTTPShouldHandleCookies:YES];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        */
        //[request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
      /*  [request setValue:@"ISO-8859-1,utf-8;q=0.7,*;q=0.3" forHTTPHeaderField:@"Accept-Charset"];
        [request setValue:@"gzip,deflate,sdch" forHTTPHeaderField:@"Accept-Encoding"];
        [request setValue:@"en-US,en;q=0.8" forHTTPHeaderField:@"Accept-Language"];
        [request setValue:@"max-age=0" forHTTPHeaderField:@"Cache-Control"];
        [request setValue:@"keep-alive" forHTTPHeaderField:@"Connection"];
        [request setValue:@"https%3A%2F%2Fwww.rhythmjuice.com%2Fsandbox%2Findex.php%3Foption%3Dcom_community%26view%3Dfrontpage" forHTTPHeaderField:@"currentURI"];
        [request setValue:@"www.rhythmjuice.com" forHTTPHeaderField:@"host"];
        [request setValue:@"https://www.rhythmjuice.com" forHTTPHeaderField:@"origin"];
        [request setValue:@"https://www.rhythmjuice.com/sandbox/index.php?option=com_user&view=login" forHTTPHeaderField: @"referer"];
        
        
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        */
        
        ret = true;
        
        self.state = 2; 
        
        [request setDelegate:self];
            NSLog(@"Request  HEADERS: %@", [request requestHeaders]);
        
        [request startAsynchronous];
            NSLog(@"Request  HEADERS: %@", [request requestHeaders]);
 //       [self getRequest:url withRequest:request];
  //      [request release];    
        
    } else { // state = 2
        NSDictionary *rjUserData = [NSPropertyListSerialization propertyListFromData:receivedData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
        
        [self loadAppWithRJUserData:rjUserData saveToFile:true];
        [loginViewController reset];
        
        BOOL authd = dataController.user.authenticated;
        if (loggingIn && authd) {
            [window addSubview:[navigationController view]];
        } else if (loggingIn && !authd) {
            NSString* url = @"https://www.rhythmjuice.com/sandbox/index.php?option=com_lesson&format=raw";
            //NSString* url = @"http://www.rj.isaacezer.com/index.php?option=com_iphone&format=raw";
           [self getRequest:url];
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Auth Failed" message:@"Incorrect user name or password."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            [window addSubview:[loginViewController view]];
             */
        } else { // !loggingIn
            [self logout];
        }
        state = 0;
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
        [window addSubview:[navigationController view]];
        [window makeKeyAndVisible];
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

- (void)getRequest:(NSString *) url; {
    // create the request
    
	//NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
	//										  cachePolicy:NSURLRequestUseProtocolCachePolicy
	//									  timeoutInterval:60.0];
	
	//[self getRequest:url withRequest:theRequest];
    
    [self createASIRequest:url];
}

- (void)getRequest:(NSString *) url withRequest:(NSMutableURLRequest*)request {
	
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    NSArray* a = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:url]];
                  
    NSArray* all = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];//]ForURL:[NSURL URLWithString:url]];
    
    for (int i = 0; i < [a count]; i++) {
        NSHTTPCookie* c = [a objectAtIndex:i];
        NSLog(@"cookie %@ = %@", [c name], [c value]);
    }
    
    for (int i = 0; i < [all count]; i++) {
        NSHTTPCookie* c = [all objectAtIndex:i];
        NSLog(@"cookie %@ = %@", [c name], [c value]);
    }
    
    if ( [a count] > 0 ) {
    NSDictionary            *cookieHeaders;
    cookieHeaders = [ NSHTTPCookie requestHeaderFieldsWithCookies: a ];
    [request setValue: [ cookieHeaders objectForKey: @"Cookie" ]
    forHTTPHeaderField: @"Cookie" ];
    }
    
    NSDictionary* d = [request allHTTPHeaderFields];
    // create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
	
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		receivedData=[[NSMutableData data] retain];
	} else {
		// inform the user that the download could not be made
        [self showConnectionError];
	}
}



- (void)showConnectionError {
    if (self.dataController == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Connection" message:@"Need web access to download your Rhythm Juice Lesson list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    LoginViewController *_loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:[NSBundle mainBundle]];
    
    self.rjCookies = [[[NSMutableArray alloc] init] autorelease];
    _loginViewController.delegate = self;
    self.loginViewController = _loginViewController;
    [_loginViewController release];

    // set up the table's footer view based on our UIView 'myFooterView' outlet
	CGRect newFrame = CGRectMake(0.0, 0.0, self.rootViewController.tableView.bounds.size.width, self.footer.frame.size.height);
	self.footer.backgroundColor = [UIColor clearColor];
	self.footer.frame = newFrame;
	self.rootViewController.tableView.tableFooterView = self.footer;	// note this will override UITableView's 'sectionFooterHeight' property
    
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
    } else {
        [window addSubview:[loginViewController view]];
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

- (void) logout {
    if( dataController.user != nil ) {
        [dataController.user deleteAllLessons];
        [dataController.user release];
        dataController.user = nil;
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
    
    //  [window addSubview:[rootViewController view]];
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
        //NSString* lessonName = [[NSURL URLWithString:file] lastPathComponent];
        NSLog(@"Checking file %@", file);
        if ( [validLessonsNames containsObject:file] ) {
            [[[dataController user] getLesson:file] cleanupDirectory];
        } else {
            NSError *error;
            [fileManager removeItemAtPath:file error:&error];
        }
    }
    
    [fileManager release];
}

- (void)createASIRequest:(NSString*)path {
    NSURL* chapter_remote_url = [NSURL URLWithString:path];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:chapter_remote_url];
    [request setUseCookiePersistence:NO];
    
        [request setRequestCookies:rjCookies];
    
        [request setDelegate:self];
        [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString = [request responseString];
    
    NSLog(@"STATUS CODE: %i", [request responseStatusCode]);
    NSLog(@"STATUS MESSAGE: %@", [request responseStatusMessage]);
    NSLog(@"Request  HEADERS: %@", [request requestHeaders]);
    NSLog(@"RESPONSE HEADERS: %@", [request responseHeaders]);
    
    NSArray* a = [request responseCookies];
    [[self rjCookies] removeAllObjects];
    [[self rjCookies] addObjectsFromArray:a];
    for (int i = 0; i < [a count]; i++) {
        NSHTTPCookie* c = [a objectAtIndex:i];
        NSLog(@"cookie %@ = %@", [c name], [c value]);
    }
    
    [self handleData:responseString];
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

@end
