//
//  LessonPlan.m
//  SimpleDrillDown
//
//  Created by  on 12-03-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LessonPlan.h"

@implementation LessonPlan

@synthesize title, lessons;

- (LessonPlan*)init:(NSString*)_title lessons:(ListOfLessons*)_lessons {
    self = [super init];
    if (self != nil)
    {
        self.title = _title;
        self.lessons = _lessons;
    }
    return self;
}


@end
