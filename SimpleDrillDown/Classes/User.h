//
//  User.h
//  SimpleDrillDown
//
//  Created by  on 11-10-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Lesson.h"

@interface User : NSObject {

    NSString* username;
    NSDate* subscriptionEndDate;
    Boolean premium;
    Boolean authenticated;
    NSMutableArray* lessons;
    NSMutableArray* playlists;
    NSMutableArray* lessonPlans;
    NSInteger allowedOfflineVideos;
}

- (User*)init:(NSString*)_username subscriptionEndDate:(NSDate*)_subscriptionEndDate premium:(Boolean)premium authenticated:(Boolean)_authenticated lessons:(NSMutableArray*)_lessons allowedOfflineLessons:(NSInteger)_allowedOfflineLessons;

- (void) downloadAllLessons;
- (void) deleteAllLessons;
- (Lesson*) getLesson:(NSString*)lessonName;

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSDate* subscriptionEndDate;
@property (nonatomic) Boolean premium;
@property (nonatomic) Boolean authenticated;
@property (nonatomic, retain, readwrite) NSMutableArray* lessons;
@property (nonatomic, retain, readwrite) NSMutableArray* playlists;
@property (nonatomic, retain, readwrite) NSMutableArray* lessonPlans;
@property (nonatomic) NSInteger allowedOfflineVideos;

@end
