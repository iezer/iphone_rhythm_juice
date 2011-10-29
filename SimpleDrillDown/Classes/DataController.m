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


@interface DataController ()
@property (nonatomic, copy, readwrite) NSMutableArray *list;
- (void)createDemoData;
@end


@implementation DataController

@synthesize list, allowedDownloads;


- (id)init {
    if (self = [super init]) {
        [self createDemoData];
    }
    self->allowedDownloads = 1;
    return self;
}

- (id)init:(NSDictionary *)data {
    if (self = [super init]) {
        [self createDataFromRequest:data];
    }
    self->allowedDownloads = 1;
    return self;
}

// Custom set accessor to ensure the new list is mutable
- (void)setList:(NSMutableArray *)newList {
    if (list != newList) {
        [list release];
        list = [newList mutableCopy];
    }
}

// Accessor methods for list
- (unsigned)countOfList {
    return [list count];
}

- (Lesson *)objectInListAtIndex:(unsigned)theIndex {
    return [list objectAtIndex:theIndex];
}


- (void)dealloc {
    [list release];
    [super dealloc];
}

- (void)createDemoData {
    
    /*
     Create an array containing some demonstration data.
     Each data item is a Play that contains information about a play -- its list of characters, its genre, and its year of publication.  Typically the data would be comprised of instances of custom classes rather than dictionaries, but using dictionaries means fewer distractions in the example.
     */
    
    NSMutableArray *playList = [[NSMutableArray alloc] init];
    Lesson *play;
    NSArray *instructors;
	NSArray *chapters;
	NSArray *chapterTitles;
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
	play = [[Lesson alloc] init];
	play.title = @"Hand To Hand";
	instructors = [[NSArray alloc] initWithObjects:@"Dax", @"Alice", nil];
	//chapters = [[NSArray alloc] initWithObjects:@"sylvia-nick", @"Movie", nil];
	chapters = [[NSArray alloc] initWithObjects:@"alhc-2008-dax-alice", @"dax-alice-toulouse", nil];
	chapterTitles = [[NSArray alloc] initWithObjects:@"Intro", @"With Music", nil];
	play.instructors = instructors;
	play.chapters = chapters;
	play.chapterTitles = chapterTitles;
    [instructors release];
	[chapters release];
	[chapterTitles release];
	[playList addObject:play];
    [play release];
    
	play = [[Lesson alloc] init];
	play.title = @"Groove Walk";
	instructors = [[NSArray alloc] initWithObjects:@"Dax", @"Alice", nil];
	//chapters = [[NSArray alloc] initWithObjects:@"sylvia-nick", @"Movie", nil];
	chapters = [[NSArray alloc] initWithObjects:@"alhc-2008-dax-alice", @"dax-alice-toulouse", nil];
	chapterTitles = [[NSArray alloc] initWithObjects:@"Intro", @"With Music", nil];
    play.instructors = instructors;
	play.chapters = chapters;
	play.chapterTitles = chapterTitles;
	[instructors release];
	[chapters release];
    [chapterTitles release];
	[playList addObject:play];
    [play release];
	
    self.list = playList;
    [playList release];
    [dateComponents release];
    [calendar release];
}

// return true if it works, false if there was an error
- (Boolean)createDataFromRequest:(NSDictionary *)data {
    
    /*
     Create an array containing some demonstration data.
     Each data item is a Play that contains information about a play -- its list of characters, its genre, and its year of publication.  Typically the data would be comprised of instances of custom classes rather than dictionaries, but using dictionaries means fewer distractions in the example.
     */
	
	NSDictionary* user = [data objectForKey:@"RJ User"];
    
    //NSNumber* authenticated = [user objectForKey:@"Authenticated"];
    
    if( true )//[authenticated boolValue] )
    {
        
        //NSString* username = [user objectForKey:@"username"];
        
        NSArray* lessons = [user objectForKey:@"Lessons"];
        
        NSMutableArray *playList = [[NSMutableArray alloc] init];
        
        for(NSDictionary* lesson in lessons) {
            Lesson *play = [[Lesson alloc] init];
            
            play.title = [lesson objectForKey:@"Title"];
            NSArray *instructors = [lesson objectForKey:@"Instructors"];
            NSArray *chapters = [lesson objectForKey:@"Chapter Paths"];
            NSArray *chapterTitles = [lesson objectForKey:@"Chapter Titles"];
            
            play.instructors = instructors;
            play.chapters = chapters;
            play.chapterTitles = chapterTitles;
            
            [playList addObject:play];
            [play release];
        }
        
        self.list = playList;
        [playList release];
    }
    
    return true;
}

- (NSInteger)numberOfDownloadedLessons
{
    NSInteger count = 0;
    for (Lesson* lesson in [self list]) {
        if ([lesson isDownloadedLocally]){
            count++;
        }
    }
    return count;
}

- (Boolean)canWatchLesson:(Lesson*)lesson
{
    return ( [lesson isDownloadedLocally] 
        || ([self allowedDownloads] == -1) 
        || ([self numberOfDownloadedLessons] < [self allowedDownloads]) );
}
@end
