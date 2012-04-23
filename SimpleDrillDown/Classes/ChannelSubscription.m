//
//  ChannelSubscription.m
//  SimpleDrillDown
//
//  Created by  on 12-04-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ChannelSubscription.h"

@implementation ChannelSubscription

@synthesize channelName, endDate, status;

- (ChannelSubscription*)init:(NSString*)_channelName endDate:(NSDate*)_endDate status:(SubscriptionStatus)_status {
    self = [super init];
    if (self != nil)
    {
        self.channelName = _channelName;
        self.endDate = _endDate;
        self.status = _status;
    }
    return self;
}

@end
