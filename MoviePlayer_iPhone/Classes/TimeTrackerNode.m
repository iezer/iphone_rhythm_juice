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
	NSString* ret = [NSString stringWithFormat:@"%@\nelapsed:%1.2f\n%@\n",
					 [self.mStartDate description], 
					 self.mElapsed,
					 self.mName ];
	return ret;
}

- (void)dealloc {
    [mName release];
	[mStartDate release];
    [super dealloc];
}

@end
