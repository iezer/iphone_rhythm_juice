//
//  TimeTracker.h
//  HelloWorld
//
//  Created by Isaac on 16/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeTrackerNode.h"

@interface TimeTracker : NSObject {
	NSMutableArray *mList;
	NSTimeInterval mStart;
	NSDate* mStartDate;
	NSString *mName;
}

@property (nonatomic, copy) NSMutableArray *mList;
@property NSTimeInterval mStart;
@property (nonatomic, retain) NSDate* mStartDate;
@property (nonatomic, copy) NSString *mName;

- (void)play:(NSString*)name;
- (TimeTrackerNode*)stop;

@end
