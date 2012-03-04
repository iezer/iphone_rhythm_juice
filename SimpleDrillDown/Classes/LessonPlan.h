//
//  LessonPlan.h
//  SimpleDrillDown
//
//  Created by  on 12-03-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LessonPlan : NSObject {

NSString *title;
NSMutableArray *lessons;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableArray *lessons;

- (LessonPlan*)init:(NSString*)_title lessons:(NSArray*)_lessons;

@end
