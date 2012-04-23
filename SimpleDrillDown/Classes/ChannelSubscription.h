//
//  ChannelSubscription.h
//  SimpleDrillDown
//
//  Created by  on 12-04-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    Cancel = 1,
    Renew = 2
};
typedef NSUInteger SubscriptionStatus;

@interface ChannelSubscription : NSObject {
    NSString *channelName;
    NSDate *endDate;
    SubscriptionStatus status;
}

@property (nonatomic, retain) NSString *channelName;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic) SubscriptionStatus status;

- (ChannelSubscription*)init:(NSString*)_channelName endDate:(NSDate*)_endDate status:(SubscriptionStatus)_status;

@end
