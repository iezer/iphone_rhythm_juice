/*
 File: DetailViewController.m
 Abstract: Creates a grouped table view to act as an inspector.
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

#import "SingleLessonViewController.h"
#import "Lesson.h"
#import "DataController.h"
#import "SimpleDrillDownAppDelegate.h"
#import "TimeTrackerNode.h"
#import "CustomMoviePlayerViewController.h"
#import "Chapter.h"

@implementation SingleLessonViewController

@synthesize lesson, dataController;


#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    
    // Scroll the table view to the top before it appears
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    self.title = lesson.title;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	/*
	 The number of rows varies by section.
	 */
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = [lesson.chapters count];
            break;
        case 1:
            rows = 2;
            break;
        case 2:
			rows = 0;
            //rows = [lesson.tracker.mList count];
			break;
		default:
            break;
    }
    return rows;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 ) {
        return [lesson getEditingStyle:indexPath.row];
    } else {
        return UITableViewCellEditingStyleNone; 
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:13.0];
    }
    
    // Cache a date formatter to create a string representation of the date object.
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy"];
    }
    
    // Set the text in the cell for the section/row.
    
    NSString *cellText = nil;
    //TimeTrackerNode *node = nil;
	
    switch (indexPath.section) {
        case 0:
            cellText = [lesson getChapterTitle:indexPath.row];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = [lesson status:indexPath.row];
            [cell setEditing:true animated:false];
            
            Chapter *c = [lesson.chapters objectAtIndex:indexPath.row];
            [cell.contentView addSubview:[c progressView]];
            break;
        case 1:
            /*            node = [lesson.tracker.mList objectAtIndex:indexPath.row];
             if (node == nil) {
             cellText = @"";
             } else {
             cellText = [node description];
             } */
			break;
		default:
            break;
    }
    
    cell.textLabel.text = cellText;
    return cell;
}



#pragma mark -
#pragma mark Section header titles

/*
 HIG note: In this case, since the content of each section is obvious, there's probably no need to provide a title, but the code is useful for illustration.
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *title = nil;
    switch (section) {
        case 0:
            title = NSLocalizedString(@"Chapters", @"Genre section title");
            break;
        case 1:
            title = @""; // Manage
            break;
        case 2:
			title = @""; // View Tracker
			break;
		default:
            break;
    }
    return title;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSUInteger section = [indexPath indexAtPosition:0];
	NSUInteger chapter = [indexPath indexAtPosition:1];
	
	if (section == 0) {
        
        if ([dataController canWatchLesson:lesson]){
            
            if([lesson isChapterDownloadedLocally:chapter])
            {
                // Create custom movie player   
                moviePlayer = [[[CustomMoviePlayerViewController alloc] initWithPlay:lesson chapterIndex:chapter] autorelease];
                
                // Show the movie player as modal
                [self presentModalViewController:moviePlayer animated:YES];
                
                // Prep and play the movie
                [moviePlayer readyPlayer];
            } else {
                lesson.detailViewController = self;
                [lesson queueChapterDownload:chapter];
                [self.tableView reloadData];
            }
        } else if ([dataController expired:lesson]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Premium Ended" message:@"Your premium subscription has expired. Please log onto www.rhythmjuice.com and renew your subscription in order to watch this premium lesson."
                                                           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        } else {
            NSString *message = [[NSString alloc] initWithFormat:@"You can only download %d premium lesson(s) with your current subscription. Please delete some lessons or buy the iPhone Add-On from www.rhythmjuice.com.",[dataController allowedDownloads]];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Cache is Full" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
            [message release];
        }
    }
}

-(void) downloadFiles {
    lesson.detailViewController = self;
    [lesson queueAllChapters];
    [self.tableView reloadData];
}

-(void) deleteFiles {
    [lesson deleteFiles]; 
    [self.tableView reloadData];
}

/*---------------------------------------------------------------------------
 * 
 *--------------------------------------------------------------------------*/
- (void)loadMoviePlayer:(NSString *)url
{  
    
}


@end
