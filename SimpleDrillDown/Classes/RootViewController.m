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
#import "User.h"
#import "SimpleDrillDownAppDelegate.h"
#import "LessonPlanViewController.h"
#import "ListOfLessons.h"

@implementation RootViewController

@synthesize dataController, delegate;

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
    return 5;
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
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"RJ on the web";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"Refresh";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    return cell;
}

#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ListOfLessonsViewController *detailViewController = [[ListOfLessonsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    LessonPlanViewController *lp;
    
    ListOfLessons *lessons;
    switch (indexPath.row) {
        case 0:
            detailViewController.title = NSLocalizedString(@"My Lessons", @"List of My Lessons Title");
            lessons = self.dataController.user.lessons;
            detailViewController.lessons = lessons;
            break;
        case 1:
            detailViewController.title = NSLocalizedString(@"My Playlists", @"List of My Playlists Title");
            lessons = self.dataController.user.playlists;
            detailViewController.lessons = lessons;
            break;
        case 2:
            //detailViewController.title = NSLocalizedString(@"My Lesson Plans", @"List of My Lesson Plans Title");
            
            lp = [[LessonPlanViewController alloc] initWithStyle:UITableViewStyleGrouped];
            
            lp.title = NSLocalizedString(@"My Lesson Plans", @"List of My Lesson Plans Title");
            
            lp.dataController = self.dataController;
            lp.lessonPlans = self.dataController.user.lessonPlans;
            
            // Push the detail view controller.
            [[self navigationController] pushViewController:lp animated:YES];
            [lp release];
            [detailViewController release];
            return;
        case 3:
            [delegate refresh:true];
            [detailViewController release];
            return;
        case 4: // refresh
            delegate.loggingIn = true;
            [delegate loginWithStoredCredentials];
            [detailViewController release];
            return;
        default:
            break;
    }

    detailViewController.dataController = self.dataController;
    
    // Push the detail view controller.
    [[self navigationController] pushViewController:detailViewController animated:YES];
    [detailViewController release];
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
