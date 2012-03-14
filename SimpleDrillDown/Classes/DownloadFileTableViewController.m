//
//  DownloadFileTableViewController.m
//  SimpleDrillDown
//
//  Created by  on 12-03-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadFileTableViewController.h"

@implementation DownloadFileTableViewController

-(void) initToolbar {
    _downloadButton = [[UIBarButtonItem alloc] initWithImage:
                       [UIImage imageNamed:@"download-icon-30x30-color.png"]
                                                       style:UIBarButtonItemStylePlain target:self action:@selector(downloadFiles)];
	_downloadButton.title = @"Download All";
    _downloadButton.tag = 1;
	_downloadButton.enabled = YES;
    
    
    _deleteButton = [[UIBarButtonItem alloc] initWithImage:
                     [UIImage imageNamed:@"logout-icon-30x30.png"]
                                                     style:UIBarButtonItemStylePlain target:self action:@selector(deleteFiles)];
	_deleteButton.title = @"Delete All";
    _deleteButton.tag = 2;
	_deleteButton.enabled = YES;
	
	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	_toolbar = [[UIToolbar alloc] initWithFrame:
				CGRectMake(0, 460 - 44, 320, 44)];
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_toolbar.tintColor = [UIColor blackColor];
	_toolbar.items = [NSArray arrayWithObjects:
					  _downloadButton, space, _deleteButton, nil];
    
    //  [self.view addSubview:_toolbar];
    //    self.tableView.tableFooterView = _toolbar;
    self.tableView.tableHeaderView = _toolbar;
}

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    [self initToolbar];
}

-(void) downloadFiles{
}

-(void) deleteFiles{
}




@end
