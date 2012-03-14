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
}

-(void) downloadFiles;
-(void) deleteFiles;

@end
