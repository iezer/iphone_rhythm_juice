//
//  User.m
//  SimpleDrillDown
//
//  Created by  on 11-10-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "Lesson.h"
#import "ListOfLessons.h"
#import "ChannelSubscription.h"

@implementation User

@synthesize username, subscriptionEndDate, premium, authenticated, lessons, playlists, allowedOfflineVideos, lessonPlans, channelSubscriptions;

- (User*)init:(NSString*)_username subscriptionEndDate:(NSDate*)_subscriptionEndDate premium:(Boolean)_premium authenticated:(Boolean)_authenticated lessons:(NSMutableArray*)_lessons allowedOfflineLessons:(NSInteger)_allowedOfflineLessons channelSubscriptions:(NSArray*)_channelSubscriptions
{
    self = [super init];
    if (self != nil)
    {
        self.username = _username;
        self.subscriptionEndDate = _subscriptionEndDate;
        self.premium = premium;
        self.authenticated = _authenticated;
        ListOfLessons* _listOfLessons = [[ListOfLessons alloc] init:_lessons];
        self.lessons = _listOfLessons;
        [_listOfLessons release];
        
        self.allowedOfflineVideos = _allowedOfflineLessons;
        NSMutableArray* channels = [[NSMutableArray alloc] initWithArray:_channelSubscriptions];
        self.channelSubscriptions = channels;
        [channels release];
    }
    return self;
}

- (void)update:(User*) u {
    self.username = u.username;
    self.subscriptionEndDate = u.subscriptionEndDate;
    self.premium = u.premium;
    self.authenticated = u.authenticated;
    self.allowedOfflineVideos = u.allowedOfflineVideos;
    
    [self.lessons update:u.lessons];
    [self.playlists update:u.playlists];
    
    [self.lessonPlans removeAllObjects];
    [self.lessonPlans addObjectsFromArray:u.lessonPlans];
    
    [self.channelSubscriptions removeAllObjects];
    [self.channelSubscriptions addObjectsFromArray:u.channelSubscriptions];
}

/*
 // Custom set accessor to ensure the new list is mutable
 - (void)setLessons:(NSMutableArray *)newLessons {
 if (lessons != newLessons) {
 [lessons release];
 lessons = [newLessons mutableCopy];
 }
 }*/

- (void) logout {    
    self.authenticated = false;
    
    [lessons clear];
    [playlists clear];
    [lessonPlans removeAllObjects];
    [channelSubscriptions removeAllObjects];
    self.username = @"";
}

- (Lesson*) getLesson:(NSString*)lessonName {
    for (int i = 0; i < [lessons count]; i++ ) {
        Lesson* l = [lessons objectInLessonsAtIndex:i];
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
    [playlists release];
    [lessonPlans release];
    [channelSubscriptions release];
	[super dealloc];
}

@end
