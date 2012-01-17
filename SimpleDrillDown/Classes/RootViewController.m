//
//  RootViewController.m
//  SimpleDrillDown
//
//  Created by  on 12-01-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"

#import "ListOfLessonsViewController.h"
#import "DataController.h"
#import "SingleLessonViewController.h"
#import "Lesson.h"
#import "SimpleDrillDownAppDelegate.h"
#import "User.h"

@implementation RootViewController


@synthesize dataController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Rhythm Juice", @"Master view navigation title");
}

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    
    // Scroll the table view to the top before it appears
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = [indexPath indexAtPosition:0];
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriat;e type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"My Lessons";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"My Playlists";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"My Lesson Plans";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ListOfLessonsViewController *detailViewController = [[ListOfLessonsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    switch (indexPath.row) {
        case 0:
            detailViewController.title = NSLocalizedString(@"My Lessons", @"List of My Lessons Title");
            break;
        case 1:
            detailViewController.title = NSLocalizedString(@"My Playlists", @"List of My Playlists Title");
            break;
        case 2:
            detailViewController.title = NSLocalizedString(@"My Lesson Plans", @"List of My Lesson Plans Title");
            break;
        default:
            break;
    }

    NSMutableArray *l = self.dataController.user.lessons;
    detailViewController.lessons = l;
    
    detailViewController.dataController = self.dataController;
    
    // Push the detail view controller.
    [[self navigationController] pushViewController:detailViewController animated:YES];
    [detailViewController release];
    
    /* 
    NSUInteger section = [indexPath indexAtPosition:0];
    
    if (section == 0 ) {
        */
        /*
         When a row is selected, create the detail view controller and set its detail item to the item associated with the selected row.
         */
  /*      SingleLessonViewController *detailViewController = [[SingleLessonViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        Lesson* lesson = [dataController objectInListAtIndex:indexPath.row];
        detailViewController.lesson = lesson;
        detailViewController.dataController = dataController;
        
        // Push the detail view controller.
        [[self navigationController] pushViewController:detailViewController animated:YES];
        [detailViewController release];
    } else if (section == 1) {
        if (indexPath.row == 0) {
            [[dataController user] downloadAllLessons];
        } else {
            [[dataController user] deleteAllLessons]; 
        }
        [self.tableView reloadData];
    } */
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
    [dataController release];
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
