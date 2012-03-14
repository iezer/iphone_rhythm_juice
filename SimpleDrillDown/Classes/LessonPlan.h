//
//  LessonPlan.h
//  SimpleDrillDown
//
//  Created by  on 12-03-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ListOfLessons;

@interface LessonPlan : NSObject {

NSString *title;
ListOfLessons *lessons;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) ListOfLessons *lessons;

- (LessonPlan*)init:(NSString*)_title lessons:(ListOfLessons*)_lessons;

@end
