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
#import "RootViewController.h"
#import "DataController.h"
#import "DetailViewController.h"
//#import "TimeTrackerNode.h"

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
@synthesize userData;

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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    // release the connection, and the data object
	
	NSDictionary *rjUserData = [NSPropertyListSerialization propertyListFromData:receivedData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];

    [self loadAppWithRJUserData:rjUserData saveToFile:true];
    
    [receivedData release];	
	[connection release];
}

- (void)loadAppWithRJUserData:(NSDictionary *)rjUserData saveToFile:(Boolean)save_to_file
{
	self.userData = rjUserData;
	
	// Create the data controller.
	DataController *controller = [[DataController alloc] init:self.userData];
    
    self.dataController = controller;
    
    [controller release];
    
	rootViewController.dataController = dataController;
    
    if (save_to_file) {
        // If we got to here the file is in good shape so save it for next time
        NSFileManager *     fileManager;
        fileManager = [NSFileManager defaultManager];
        assert(fileManager != nil);
        
        NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *rj_user_info_path = [document_folder_path stringByAppendingPathComponent:@"rj_user_info.plist"];
        
        BOOL written = [rjUserData writeToFile:rj_user_info_path atomically:NO];
        if (written)
            NSLog(@"Saved to file: %@", rj_user_info_path);
    }
    
    /*
	 The navigation and root view controllers are created in the main nib file.
	 Configure the window with the navigation controller's view and then show it.
	 */
    [window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

- (void)getRequest:(NSString *) url; {
    // create the request

	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:60.0];
	
	// create the connection with the request
	// and start loading the data
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	
	if (theConnection) {
		// Create the NSMutableData that will hold
		// the received data
		// receivedData is declared as a method instance elsewhere
		receivedData=[[NSMutableData data] retain];
	} else {
		// inform the user that the download could not be made
	}
}

- (Boolean)isAuthenticated:(NSDictionary *)rjUserData{
	NSDictionary* user = [rjUserData objectForKey:@"RJ User"];
    NSNumber* authenticated = [user objectForKey:@"Authenticated"];
    return [authenticated boolValue];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
    // Check if we already have user storage saved
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *rj_user_info_path = [document_folder_path stringByAppendingPathComponent:@"rj_user_info.plist"];
    
    if ( ! [fileManager fileExistsAtPath:rj_user_info_path]) {
        // Get the user info from the server
        // NSString* user_data_url = @"http://rj.isaacezer.com/index.php?option=com_user&view=login&tmpl=component";
        //NSString* user_data_url = @"http://rj.isaacezer.com/index.php?option=com_iphone&format=raw";
        NSString* user_data_url = @"http://localhost/rj/userdata.plist";
        [self getRequest:user_data_url];
    } else {
        NSDictionary* data = [[NSDictionary alloc] initWithContentsOfFile:rj_user_info_path];
        [self loadAppWithRJUserData:data saveToFile:false];
        [data release];
    }
    
   // [self cleanDiskOfUneededVideos]; // @TODO Make run in background
}
/*
- (void)cleanDiskOfUneededVideos{
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *localFileManager = [document_folder_path stringByAppendingPathComponent:@"lessons"]; 

    
    NSDirectoryEnumerator *dirEnum =
    [fileManager enumeratorAtPath:localFileManager];
    
    NSString *file;
    while (file = [dirEnum nextObject]) {
        if ([[file pathExtension] isEqualToString: @"doc"]) {
            // process the document
            [self scanDocument: [docsDir stringByAppendingPathComponent:file]];
        }
    }
    [fileManager release];


}*/


- (void)dealloc {
    [navigationController release];
	[rootViewController release];
    [window release];
    [dataController release];
	[play release];
    [userData release];
    [receivedData release];
    [super dealloc];
}

@end
