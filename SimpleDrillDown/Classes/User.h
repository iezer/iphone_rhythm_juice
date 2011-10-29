//
//  User.h
//  SimpleDrillDown
//
//  Created by  on 11-10-23.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject {

    NSString* firstName;
    NSString* lastName;
    NSString* username;
    NSDate* subscriptionEndDate;
    Boolean premium;
    Boolean authenticated;
    Boolean unlimited;
    NSMutableArray* lessons;
    NSInteger allowedOfflineLessons;
}

@end
