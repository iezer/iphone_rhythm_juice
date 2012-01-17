//
//  RootViewController.h
//  SimpleDrillDown
//
//  Created by  on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataController;

@interface RootViewController : UITableViewController {
    DataController *dataController;
}

@property (nonatomic, retain) DataController *dataController;

@end