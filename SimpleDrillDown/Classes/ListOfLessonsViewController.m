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
#import <QuartzCore/QuartzCore.h>
#import "ListOfLessons.h"

@implementation ListOfLessonsViewController

@synthesize dataController;
@synthesize lessons;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void) downloadFiles {
    [dataController downloadAllLessons:lessons];
    [self update];
}

-(Boolean) isDownloadInProgress {
    return [dataController isDownloadInProgress:lessons];
}

-(void) deleteFiles {
    if ([self isDownloadInProgress]) {
        [dataController cancelAllDownloads:lessons];
    } else {
        [dataController deleteAllLessons:lessons];
    }
    [self update];
}

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    /*
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"blue-fullbg.png"]];
    self.view.backgroundColor = background;
    [background release];
*/

    // Scroll the table view to the top before it appears
    [self update];
    [self.tableView setContentOffset:CGPointZero animated:NO];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        NSInteger i = [lessons count];
        return i > 0 ? i : 1;
    } else {
        return 2;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = [indexPath indexAtPosition:0];
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13.5];
        cell.textLabel.textColor = RJColorDarkBlue;
    }
    
    if (section == 0) {
        
        if ([lessons count] > 0) {
            
            // Get the object to display and set the value in the cell.
            Lesson *lesson = [lessons objectInLessonsAtIndex:indexPath.row];
            cell.textLabel.text = lesson.title;
            // cell.detailTextLabel.text = [] ? @"downloaded locally" : @"not downloaded";
            
            //NSString* premium = [lesson premium] ? @"premium - " : @"";
            NSString* downloadStatus = [lesson downloadStatus];
            NSString* subTitle = [[NSString alloc] initWithFormat:@"Chapters - %@", downloadStatus];
            cell.detailTextLabel.text = subTitle;
            [subTitle release];
        } else if( indexPath.row == 0 ) {
            cell.textLabel.text = @"No Lessons yet.";
            cell.detailTextLabel.text = @"";
        }
    }
    return cell;
}

#pragma mark -
#pragma mark Table view selection

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([lessons count] <= 0) {
        return;
    }
    
    NSUInteger section = [indexPath indexAtPosition:0];
    
    if (section == 0) {
        /*
         When a row is selected, create the detail view controller and set its detail item to the item associated with the selected row.
         */
        SingleLessonViewController *detailViewController = [[SingleLessonViewController alloc] initWithStyle:UITableViewStylePlain];
        
        Lesson* lesson = [lessons objectInLessonsAtIndex:indexPath.row];
        detailViewController.lesson = lesson;
        detailViewController.dataController = dataController;
        
        // Push the detail view controller.
        [[self navigationController] pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }
}

/*
 HIG note: In this case, since the content of each section is obvious, there's probably no need to provide a title, but the code is useful for illustration.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
    switch (section) {
        case 0:
            if( showToolbar )
                title = NSLocalizedString(@"Lessons", @"Lesson section title");
            break;
		default:
            break;
    }
    return title;
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
