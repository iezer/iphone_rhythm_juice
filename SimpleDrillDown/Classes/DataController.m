/*
 File: DataController.m
 Abstract: A simple controller class responsible for managing the application's data.
 Typically this object would be able to load and save a file containing the appliction's data. This example illustrates just the basic minimum: it creates an array containing information about some plays and provides simple accessor methods for the array and its contents.
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

#import "DataController.h"
#import "Lesson.h"
#import "User.h"
#import "LessonPlan.h"
#import "ListOfLessons.h"
#import "Chapter.h"
#import "ChannelSubscription.h"
#import "ASIHTTPRequest.h"

@implementation DataController

@synthesize user, videoDownloadQueue, gotLatestSettings;

- (id)init {
    self = [super init];
    self.gotLatestSettings = false;
    NSOperationQueue* queue = [[NSOperationQueue alloc] init];
    self.videoDownloadQueue = queue;
    [queue release];
    [self updatedDownloadQueueSize];
    return self;
}

- (void)updatedDownloadQueueSize {
    NSInteger queueSize = 2;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"maxConcurrentDownloads"];
    if (testValue == nil)
    {
        [defaults setValue:@"2" forKey:@"maxConcurrentDownloads"];
        [defaults synchronize];
    } else {
        queueSize = [testValue intValue];
    }
    self.videoDownloadQueue.maxConcurrentOperationCount = queueSize;
}

- (void)dealloc {
    [user release];
    [videoDownloadQueue release];
    [super dealloc];
}

// return true if it works, false if there was an error
- (Boolean)createDataFromRequest:(NSDictionary *)data {
    User* _user = [DataController createUserFromData:data];
    if (_user != nil && _user.username !=nil ) {
        if( self.user == nil )
            self.user = _user;
        else
            [self.user update:_user];
        return true;
    }
    
    return false;
}

+ (NSString*)stringByUnescapingFromURLArgument:(NSString *)s {
    
    if (s == nil) {
        return @"";
    }
    
    NSMutableString *resultString = [NSMutableString stringWithString:s];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSMutableArray*) parseLessonList:(NSArray *) lessons {
    NSMutableArray* playlist = [[[NSMutableArray alloc] init] autorelease];
    
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *lessonsFolderPath = [document_folder_path stringByAppendingPathComponent:@"videos"]; 
    
    for(NSDictionary* lesson in lessons) {
        NSString *title = [DataController stringByUnescapingFromURLArgument:[lesson objectForKey:@"Title"]];
        NSArray *instructors = [lesson objectForKey:@"Instructors"];
        Boolean premium = [[lesson objectForKey:@"Premium"] boolValue];
        
        NSMutableArray *chapters = [[NSMutableArray alloc] init];
        
        NSArray* chaptersDict = [lesson objectForKey:@"Chapters"];
        for(NSDictionary* chapter in chaptersDict) {
            NSString *title = [DataController stringByUnescapingFromURLArgument:[chapter objectForKey:@"Name"]];
            NSString *remotePath = [DataController stringByUnescapingFromURLArgument:[chapter objectForKey:@"Filename"]];
            NSInteger channel = [[chapter objectForKey:@"Channel"] intValue];
            
            NSURL* chapter_remote_url = [NSURL URLWithString:remotePath];
            NSString* filename = [chapter_remote_url lastPathComponent];
            NSString* chapterLocalPath = [lessonsFolderPath stringByAppendingPathComponent:filename];
            
            Chapter* c = [[Chapter alloc] init:title remotePath:remotePath localPath:chapterLocalPath channel:channel];
            [chapters addObject:c];
            [c release];
            
        }
        
        Lesson *play = [[Lesson alloc] init:title instructors:instructors lessonFolderPath:lessonsFolderPath chapters:chapters premium:premium];
        
        [playlist addObject:play];
        [chapters release];
        [play release];
    }
    return playlist;
}

+ (User*)createUserFromData:(NSDictionary *)data {
	
	NSDictionary* userData = [data objectForKey:@"RJ User"];
    User* user;
    
    //NSNumber* authenticated = [user objectForKey:@"Authenticated"];
    
    if( true )//[authenticated boolValue] )
    {
        
        NSArray* lessons = [userData objectForKey:@"Lessons"];
        NSMutableArray* myLessons = [DataController parseLessonList:lessons];
        
        NSArray* playlists = [userData objectForKey:@"Playlists"];
        NSMutableArray* myPlaylists = [DataController parseLessonList:playlists];
        
        NSArray* lessonPlans = [userData objectForKey:@"LessonPlans"];
        NSMutableArray* myLessonPlans = [[NSMutableArray alloc] init];
        for (NSDictionary* lp in lessonPlans) {
            NSArray* l = [lp objectForKey:@"Lessons"];
            ListOfLessons* lpl = [[ListOfLessons alloc] init:[DataController parseLessonList:l]];
            NSString* t = [DataController stringByUnescapingFromURLArgument:[lp objectForKey:@"Title"]];
            LessonPlan* plan = [[LessonPlan alloc] init:t lessons:lpl];
            
            [myLessonPlans addObject:plan];
            [lpl release];
            [plan release];
        }
        
        NSString* username = [userData objectForKey:@"Username"];        
        Boolean premium = [[userData objectForKey:@"Premium"] boolValue];
        Boolean authenticated = [[userData objectForKey:@"Authenticated"] boolValue];
        NSDate* subscriptionEndDate = [userData objectForKey:@"Subscription End"];
        NSInteger allowedOfflineLessons = [[userData objectForKey:@"Allowed Offline Lessons"] intValue];
        
        NSArray* channelSubscriptions = [userData objectForKey:@"Channels"];     
        
        user = [[[User alloc] init:username subscriptionEndDate:subscriptionEndDate premium:premium authenticated:authenticated lessons:myLessons allowedOfflineLessons:allowedOfflineLessons channelSubscriptions:channelSubscriptions] autorelease];
        
        ListOfLessons* parsedPlaylists = [[ListOfLessons alloc] init:myPlaylists];
        user.playlists = parsedPlaylists;
        
        NSArray* sortedLessonPlans = [myLessonPlans sortedArrayUsingComparator:^(LessonPlan* obj1, LessonPlan* obj2){
            return [obj1.title compare:obj2.title];  }];
        user.lessonPlans = [NSMutableArray arrayWithArray:sortedLessonPlans];
        
        [parsedPlaylists release];
        [myLessonPlans release];
    }
    
    return user;
}

- (Boolean)canWatchLesson:(Lesson*)lesson chapter:(NSInteger)chapter_index {
    if ([self allowedDownloads] == -1) {
        return true;
    }
    
    Boolean isDownloaded = [lesson isChapterDownloadedLocally:chapter_index];
    NSInteger currentAndPendingDownloads = [self numberOfDownloadedLessons] + [ videoDownloadQueue operationCount];
    
    if (isDownloaded) {
        return ([self allowedDownloads] == -1) || (currentAndPendingDownloads <= [self allowedDownloads]);
    }
    else {
        return ([self allowedDownloads] == -1) || (currentAndPendingDownloads < [self allowedDownloads]);
    }
}

- (Boolean)isFreeVideo:(Lesson*)lesson chapter:(NSInteger)chapter_index {
    Chapter* chapter = [lesson.chapters objectAtIndex:chapter_index];    
    return chapter.channel == 2;
}

- (Boolean)canWatchChapterInChannel:(Lesson*)lesson chapter:(NSInteger)chapter_index {
    Chapter* chapter = [lesson.chapters objectAtIndex:chapter_index];
    for( int i = 0; i < [[user channelSubscriptions] count]; i ++ ) {
        if ( [[user.channelSubscriptions objectAtIndex:i] intValue] == chapter.channel) {
            return true;
        }
    }
    return false;
}

- (Boolean)expired:(Lesson*)lesson {
    NSDate* now = [NSDate date];
    NSDate* endDate = [user subscriptionEndDate];
    NSComparisonResult result = [now compare:endDate];
    //NSLog(@"%@ %@ %d", now, endDate, result);
    return ( result == NSOrderedDescending );
}

- (NSInteger) allowedDownloads {
    //return [user allowedOfflineVideos];
    
    // Make configurable for now.
    NSInteger queueSize = 2;
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"numberOfAllowedVideoFiles"];
    if (testValue == nil)
    {
        [defaults setValue:@"2" forKey:@"numberOfAllowedVideoFiles"];
        [defaults synchronize];
    } else {
        queueSize = [testValue intValue];
    }
    return queueSize;
}

// Custom set accessor to ensure the new list is mutable
- (void)setUsers:(User *)newUser {
    if (user != newUser) {
        [user release];
        user = newUser;
    }
}

- (void) deleteAllLessons:(ListOfLessons *)list {
    for (int i = 0; i < [list.lessons count]; i++) {
        [[list.lessons objectAtIndex:i] deleteFiles];
    }
}

- (Boolean) downloadAllLessons:(ListOfLessons *)list {
    for (int i = 0; i < [list.lessons count]; i++) {
        if( ![self queueAllChapters:[list.lessons objectAtIndex:i]] )
            return false;
    }
    return true;
}

//Meant to be all videos, not just for 1 particular lesson
- (NSInteger)numberOfDownloadedLessons {
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *videoFolder = [document_folder_path stringByAppendingPathComponent:@"videos"]; 
    
    NSError *error;
    return [[fileManager contentsOfDirectoryAtPath:videoFolder  error:&error] count];
}

- (Boolean)queueAllChapters:(Lesson *)lesson
{
    for (int i = 0; i < [[lesson chapters] count]; i++) {
        if (![lesson isChapterDownloadedLocally:i] && ![lesson isChapterDownloadInProgress:i]) {
            if ( ! [self queueChapterDownload:lesson chapter:i] ) {
                return false;;
            }
        }
    }
    return true;
}

- (Boolean)validateChapterPlayOrDownload:(Lesson*)lesson chapter:(NSUInteger)chapter_index {
    Boolean isFreeLesson = [self isFreeVideo:lesson chapter:chapter_index];
    
    if (!isFreeLesson && [self expired:lesson]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscription Ended" message:@"Your  subscription has expired. Please log onto www.rhythmjuice.com and renew your subscription.."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    } else if (!isFreeLesson && ![self canWatchChapterInChannel:lesson chapter:chapter_index]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Channel" message:@"You are no longer subscribed to the channel containing this video."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    } else if(![lesson isVideoTypeSupported:chapter_index]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Play Video." message:@"Sorry, this video format is not supported. We are working on converting all videos to an iPhone-compatible format."
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    } else if (![self canWatchLesson:lesson chapter:chapter_index]){
        NSString *message = [[NSString alloc] initWithFormat:@"You can only download %d videos with your current subscription. Please delete some videos or buy the iPhone Add-On from www.rhythmjuice.com. [LIMIT CAN BE CHANGED IN SETTINGS FOR TESTING]",[self allowedDownloads]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Cache is Full" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        [message release];
    } else {
        // No problem
        return true;
    }
    return false;
}

- (Boolean)queueChapterDownload:(Lesson *) lesson chapter:(NSUInteger)chapter_index {
    
    // update queue size in case user changed in settings.
    [self updatedDownloadQueueSize];
    
    if (! [self validateChapterPlayOrDownload:lesson chapter:chapter_index]) {
        return false;
    }
           
    Chapter* chapter = [[lesson chapters] objectAtIndex:chapter_index];
    if ([chapter isDownloadInProgress]) {
        return true;
    }
    
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString* chapter_remote_path = [lesson getChapterRemotePath:chapter_index];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *rootURL = [defaults stringForKey:@"rootURL"];
    NSString *root = [NSString stringWithFormat:@"%@/chapters/", rootURL];
    
    //NSString* root = @"http://www.rhythmjuice.com/sandbox/chapters/";
    NSURL* chapter_remote_url = [NSURL URLWithString:[root stringByAppendingString:chapter_remote_path]];
    
    NSError *error;
    if ( ! [lesson isDownloadedLocally] ) {
        [[NSFileManager defaultManager] createDirectoryAtURL: [NSURL fileURLWithPath:[lesson lessonFolderPath]] withIntermediateDirectories:true attributes:nil error:&error];
    }
    
    if ( ! [lesson isChapterDownloadedLocally:chapter_index]) {
        [lesson setChapterDownloadInProgressFlag:chapter_index withFlag:true];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:chapter_remote_url];
        chapter.request = request;
        [request setDelegate:lesson];
        [request setDownloadProgressDelegate:[chapter progressView]];
        
        [videoDownloadQueue addOperation:request];
    }
    return true;
}

- (NSSet*) allChapterTitles {
    NSMutableSet * validLessonsNames = [[NSMutableSet alloc] init];
    [validLessonsNames unionSet:[[user lessons] chapterTitles]];
    [validLessonsNames unionSet:[[user playlists] chapterTitles]];
    for ( LessonPlan* lp in [user lessonPlans] ) {
        [validLessonsNames unionSet:[[lp lessons] chapterTitles]];
    }
    NSSet* retSet = [NSSet setWithSet:validLessonsNames];
    [validLessonsNames release];
    return retSet;
}

@end
