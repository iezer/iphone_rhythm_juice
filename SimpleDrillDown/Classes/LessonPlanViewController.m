//
//  LessonPlanViewController.m
//  SimpleDrillDown
//
//  Created by  on 12-03-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LessonPlanViewController.h"
#import "DataController.h"
#import "LessonPlan.h"
#import "ListOfLessonsViewController.h"

@implementation LessonPlanViewController

@synthesize dataController;
@synthesize lessonPlans;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
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
    return lessonPlans == nil ? 0 : [lessonPlans count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = [indexPath indexAtPosition:0];
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (section == 0) {
        
        if ([lessonPlans count] > 0) {
            
            // Get the object to display and set the value in the cell.
            LessonPlan *lp = [lessonPlans objectAtIndex:indexPath.row];
            cell.textLabel.text = lp.title;
            // cell.detailTextLabel.text = [] ? @"downloaded locally" : @"not downloaded";
            
            //NSString* subTitle = [lp downloadStatus];
            //cell.detailTextLabel.text = subTitle;
            //[subTitle release];
        } else {
            cell.detailTextLabel.text = @"No Lesson Plans yet.";
        }
    }
    
    return cell;
}

#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (lessonPlans == nil || [lessonPlans count] <= 0) {
        return;
    }
    
    NSUInteger section = [indexPath indexAtPosition:0];
    
    if (section == 0) {
        
        ListOfLessonsViewController *detailViewController = [[ListOfLessonsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        LessonPlan *lp = [lessonPlans objectAtIndex:indexPath.row];
        detailViewController.lessons = lp.lessons;
        detailViewController.dataController = self.dataController;
        
        // Push the detail view controller.
        [[self navigationController] pushViewController:detailViewController animated:YES];
        [detailViewController release];
        
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
    [dataController release];
    [lessonPlans release];
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
