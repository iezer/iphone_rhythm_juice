//
//  User.m
//  SimpleDrillDown
//
//  Created by  on 11-10-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "Lesson.h"

@implementation User

@synthesize username, subscriptionEndDate, premium, authenticated, lessons, allowedOfflineLessons;

- (User*)init:(NSString*)_username subscriptionEndDate:(NSDate*)_subscriptionEndDate premium:(Boolean)_premium authenticated:(Boolean)_authenticated lessons:(NSMutableArray*)_lessons allowedOfflineLessons:(NSInteger)_allowedOfflineLessons
{
    self.username = _username;
    self.subscriptionEndDate = _subscriptionEndDate;
    self.premium = premium;
    self.authenticated = _authenticated;
    self.lessons = _lessons;
    self.allowedOfflineLessons = _allowedOfflineLessons;
    return self;
}

// Custom set accessor to ensure the new list is mutable
- (void)setLessons:(NSMutableArray *)newLessons {
    if (lessons != newLessons) {
        [lessons release];
        lessons = [newLessons mutableCopy];
    }
}

- (void) downloadAllLessons {
    for (int i = 0; i < [lessons count]; i++) {
        [[lessons objectAtIndex:i] queueAllChapters];
    }
}

- (void) deleteAllLessons {
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *lessonFolder = [document_folder_path stringByAppendingPathComponent:@"lessons"]; 
    
    NSError *error;
    [fileManager removeItemAtPath:lessonFolder error:&error];
    // call 2nd time to delete empty directory.
    [fileManager removeItemAtPath:lessonFolder error:&error];
}

- (Lesson*) getLesson:(NSString*)lessonName {
    for (int i = 0; i < [lessons count]; i++ ) {
        Lesson* l = [lessons objectAtIndex:i];
        if ([[l title] isEqual:lessonName]) {
            return l;
        }
    }
    return nil;
}

- (void)dealloc {
    [username release];
    [subscriptionEndDate release];
    [lessons release];
	[super dealloc];
}

@end
