/*
 File: RootViewController.m
 Abstract: A table view controller to display a list of names of plays.
 Version: 2.7
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */

#import "ListOfLessonsViewController.h"
#import "DataController.h"
#import "SingleLessonViewController.h"
#import "Lesson.h"
#import "SimpleDrillDownAppDelegate.h"
#import "User.h"

@implementation ListOfLessonsViewController

@synthesize dataController;
@synthesize lessons;

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
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Only one section, so return the number of items in the list.
    return [dataController countOfList];
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
        
        // Get the object to display and set the value in the cell.
        Lesson *lesson = [lessons objectAtIndex:indexPath.row];
        cell.textLabel.text = lesson.title;
        // cell.detailTextLabel.text = [] ? @"downloaded locally" : @"not downloaded";
        
        NSString* premium = [lesson premium] ? @"premium - " : @"";
        NSString* downloaded = [lesson isDownloadedLocally] ? @"downloaded locally" : @"not downloaded";
        NSString* subTitle = [[NSString alloc] initWithFormat:@"%@%@",premium,downloaded];
        cell.detailTextLabel.text = subTitle;
        [subTitle release];
    } else if (section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Download All";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.textLabel.text = @"Delete All";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}

#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = [indexPath indexAtPosition:0];
    
    if (section == 0 ) {

	/*
     When a row is selected, create the detail view controller and set its detail item to the item associated with the selected row.
     */
    SingleLessonViewController *detailViewController = [[SingleLessonViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    Lesson* lesson = [lessons objectAtIndex:indexPath.row];
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
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
    [dataController release];
    [lessons release];
    [super dealloc];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
