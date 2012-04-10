//
//  TimeTracker.m
//  HelloWorld
//
//  Created by Isaac on 16/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TimeTracker.h"


@implementation TimeTracker

@synthesize mList;
@synthesize mStart;
@synthesize mStartDate;
@synthesize mName;

- (void)play:(NSString*)name {
	self.mName = name;
	self.mStartDate = [NSDate date];
    self.mStart = [NSDate timeIntervalSinceReferenceDate];
}

- (TimeTrackerNode*)stop {
	NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - mStart;
	TimeTrackerNode* node = [[[TimeTrackerNode alloc] initWithName:mName elapsed:elapsed starting:mStartDate] autorelease];
	[mList addObject:node];
	self.mStartDate = nil;
    self.mName = nil;
	return node;
}

- (TimeTracker*)init {
    self = [super init];
    if (self != nil)
    {
        self.mList = [[[NSMutableArray alloc] init] autorelease];
    }

	return self;
}

- (void)dealloc {
	[mList release];
	[mStartDate release];
	[mName release];
	[super dealloc];
}

@end
