//
//  DownloadFileTableViewController.m
//  SimpleDrillDown
//
//  Created by  on 12-03-14.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DownloadFileTableViewController.h"
#import "ColourMacro.h"

@implementation DownloadFileTableViewController

@synthesize showToolbar;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    self.showToolbar = false;
    
    //self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue-fullbg.png"]] autorelease];
    
    return self;
}

-(void) initToolbar {
    
    if( !self.showToolbar )
        return;
    
    _downloadButton = [[UIBarButtonItem alloc] initWithTitle:@"Download All"
                                                       style:UIBarButtonItemStyleDone target:self action:@selector(downloadFiles)];
    _downloadButton.tag = 1;
	_downloadButton.enabled = YES;
    _downloadButton.tintColor = RJColorGreen;
    
    _deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete All"
                                                     style:UIBarButtonItemStyleDone target:self action:@selector(deleteFiles)];
    _deleteButton.tag = 2;
	_deleteButton.enabled = YES;
    _deleteButton.tintColor = RJColorRed;
	
	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	_toolbar = [[UIToolbar alloc] initWithFrame:
				CGRectMake(0, 460 - 44, 320, 44)];
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_toolbar.tintColor = [UIColor whiteColor];
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

-(Boolean) isDownloadInProgress {
    return false;
}

-(void) update {
    if ([self isDownloadInProgress]) {
        _deleteButton.title = @"Cancel Downloads";
    } else {
        _deleteButton.title = @"Delete All";
    }
    [self.tableView reloadData];
}

@end
