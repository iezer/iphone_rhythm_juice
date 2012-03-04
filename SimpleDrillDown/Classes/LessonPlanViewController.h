//
//  LessonPlanViewController.h
//  SimpleDrillDown
//
//  Created by  on 12-03-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataController;

@interface LessonPlanViewController : UITableViewController {
    DataController *dataController;
    NSArray* lessonPlans;
}

@property (nonatomic, retain) DataController *dataController;
@property (nonatomic, retain) NSArray* lessonPlans;

@end
