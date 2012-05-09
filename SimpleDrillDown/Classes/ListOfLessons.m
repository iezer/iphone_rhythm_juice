//
//  ListOfLessons.m
//  SimpleDrillDown
//
//  Created by  on 12-03-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListOfLessons.h"
#import "Lesson.h"

@implementation ListOfLessons

@synthesize lessons;

- (ListOfLessons*) init:(NSMutableArray*) l {
    NSArray* sorted = [l sortedArrayUsingComparator:^(Lesson* obj1, Lesson* obj2){
        return [obj1.title compare:obj2.title];  }];
    self.lessons = [NSMutableArray arrayWithArray:sorted];
    return self;
}

- (NSInteger)numberOfDownloadedLessons
{
    NSInteger count = 0;
    for (Lesson* lesson in self.lessons) {
        if ([lesson isDownloadedLocally]){
            count++;
        }
    }
    return count;
}

- (void) deleteAllLessons {
    for (int i = 0; i < [lessons count]; i++) {
        [[lessons objectAtIndex:i] deleteFiles];
    }
}

- (void) downloadAllLessons {
    for (int i = 0; i < [lessons count]; i++) {
        [[lessons objectAtIndex:i] queueAllChapters];
    }
}

- (void) clear {
    [lessons removeAllObjects];
}

- (NSInteger) count {
    return [lessons count];
}

- (Lesson*) objectInLessonsAtIndex:(NSUInteger)index {
    return [lessons objectAtIndex:index];
}

- (void)update:(ListOfLessons*) l {
    [self clear];
    [lessons addObjectsFromArray:l.lessons];
}

- (void)dealloc {
    [lessons release];
	[super dealloc];
}

@end
