//
//  User.m
//  SimpleDrillDown
//
//  Created by  on 11-10-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "User.h"

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

- (void)dealloc {
    [username release];
    [subscriptionEndDate release];
    [lessons release];
	[super dealloc];
}

@end
