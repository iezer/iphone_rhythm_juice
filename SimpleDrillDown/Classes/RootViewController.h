//
//  RootViewController.h
//  SimpleDrillDown
//
//  Created by  on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataController;
@class SimpleDrillDownAppDelegate;

@interface RootViewController : UITableViewController {
    DataController *dataController;
    SimpleDrillDownAppDelegate *delegate;
}

@property (nonatomic, retain) DataController *dataController;
@property (nonatomic, retain) SimpleDrillDownAppDelegate *delegate;

@end