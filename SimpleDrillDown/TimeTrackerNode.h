//
//  TimeTrackerNode.h
//  HelloWorld
//
//  Created by Isaac on 17/01/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TimeTrackerNode : NSObject {
	NSString *mName;
	NSTimeInterval mElapsed;
	NSDate *mStartDate;
}

@property (nonatomic, copy) NSString *mName;
@property NSTimeInterval mElapsed;
@property (nonatomic, copy) NSDate *mStartDate;

- (TimeTrackerNode*)initWithName:(NSString *)name elapsed:(NSTimeInterval)elapsed starting:(NSDate*)startDate;
- (NSString *)description;

@end
