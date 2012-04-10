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

@implementation DataController

@synthesize user, gotLatestSettings;

- (id)init {
    self = [super init];
    self.gotLatestSettings = false;
    return self;
}

- (void)dealloc {
    [user release];
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
    NSMutableString *resultString = [NSMutableString stringWithString:s];
    [resultString replaceOccurrencesOfString:@"+"
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, [resultString length])];
    return [resultString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSMutableArray*) parseLessonList:(NSArray *) lessons {
    NSMutableArray* playlist = [[[NSMutableArray alloc] init] autorelease];
    
    for(NSDictionary* lesson in lessons) {
        NSString *title = [DataController stringByUnescapingFromURLArgument:[lesson objectForKey:@"Title"]];
        NSArray *instructors = [lesson objectForKey:@"Instructors"];
        Boolean premium = [[lesson objectForKey:@"Premium"] boolValue];
        
        NSMutableArray *chapterTitles = [[NSMutableArray alloc] init];
        NSMutableArray *chapterPaths = [[NSMutableArray alloc] init];
        NSArray* chapters = [lesson objectForKey:@"Chapters"];
        for(NSDictionary* chapter in chapters) {
            NSString *title = [DataController stringByUnescapingFromURLArgument:[chapter objectForKey:@"Name"]];
            NSString *filename = [DataController stringByUnescapingFromURLArgument:[chapter objectForKey:@"Filename"]];
            
            [chapterTitles addObject:title];
            [chapterPaths addObject:filename];
        }

        Lesson *play = [[Lesson alloc] init:title instructors:instructors chapters:chapterPaths chapterTitles:chapterTitles premium:premium];
        
        [playlist addObject:play];
        [play release];
        [chapterPaths release];
        [chapterTitles release];
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
        
        user = [[[User alloc] init:username subscriptionEndDate:subscriptionEndDate premium:premium authenticated:authenticated lessons:myLessons allowedOfflineLessons:allowedOfflineLessons] autorelease];
        
        ListOfLessons* parsedPlaylists = [[ListOfLessons alloc] init:myPlaylists];
        user.playlists = parsedPlaylists;
        user.lessonPlans = myLessonPlans;
        
        [parsedPlaylists release];
        [myLessonPlans release];
    }
    
    return user;
}

- (Boolean)canWatchLesson:(Lesson*)lesson {
    return ( [lesson isDownloadedLocally] 
            || ([self allowedDownloads] == -1) 
            || ([self numberOfDownloadedLessons] < [self allowedDownloads]) );
}

- (Boolean)expired:(Lesson*)lesson {
    NSDate* now = [NSDate date];
    return ( [lesson premium] && ( now > [user subscriptionEndDate] || ! [user premium] ) );
}

- (NSInteger) allowedDownloads {
    return [user allowedOfflineVideos];
}

// Custom set accessor to ensure the new list is mutable
- (void)setUsers:(User *)newUser {
    if (user != newUser) {
        [user release];
        user = newUser;
    }
}

- (NSInteger)numberOfDownloadedLessons {
    return 0;
}

@end
