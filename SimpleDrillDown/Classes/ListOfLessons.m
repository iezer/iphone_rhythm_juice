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
    self.lessons = l;
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

- (void)dealloc {
    [lessons release];
	[super dealloc];
}

@end
