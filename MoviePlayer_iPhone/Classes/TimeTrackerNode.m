//
//  TimeTrackerNode.m
//  HelloWorld
//
//  Created by Isaac on 17/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TimeTrackerNode.h"


@implementation TimeTrackerNode

@synthesize mName;
@synthesize mElapsed;
@synthesize mStartDate;

- (TimeTrackerNode*)initWithName:(NSString *)name elapsed:(NSTimeInterval)elapsed starting:(NSDate*)startDate {
	self.mName = name;
	self.mElapsed = elapsed;
	self.mStartDate = startDate;
	return self;
}

- (NSString*)description {
	NSString* ret = [NSString stringWithFormat:@"%@ %@ elapsed:%1.2f",
					 self.mName, 
					 [self.mStartDate description], 
					 self.mElapsed	];
	return ret;
}

- (void)dealloc {
    [mName release];
	[mStartDate release];
    [super dealloc];
}

@end
