//
//  ListOfLessons.h
//  SimpleDrillDown
//
//  Created by  on 12-03-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Lesson;

@interface ListOfLessons : NSObject {
    NSMutableArray* lessons;
}

@property (nonatomic, retain, readwrite) NSMutableArray* lessons;

- (ListOfLessons*) init:(NSMutableArray*) l;
- (NSInteger)numberOfDownloadedLessons;
- (void) clear;
- (NSInteger) count;
- (Lesson*) objectInLessonsAtIndex:(NSUInteger)index;
- (void)update:(ListOfLessons*) l;
- (NSSet*) chapterTitles;

@end
