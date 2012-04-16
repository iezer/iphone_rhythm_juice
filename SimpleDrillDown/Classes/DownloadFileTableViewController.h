//
//  DownloadFileTableViewController.h
//  SimpleDrillDown
//
//  Created by  on 12-03-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadFileTableViewController : UITableViewController {
    UIToolbar* _toolbar;
    UIBarButtonItem* _downloadButton;
    UIBarButtonItem* _deleteButton;
    Boolean showToolbar;
}

@property (nonatomic) Boolean showToolbar;

- (id)initWithStyle:(UITableViewStyle)style;
-(void) downloadFiles;
-(void) deleteFiles;

@end
