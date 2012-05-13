//
//  CustomMoviePlayerViewController.m
//
//  Copyright iOSDeveloperTips.com All rights reserved.
//

#import "CustomMoviePlayerViewController.h"

#pragma mark -
#pragma mark Compiler Directives & Static Variables

@implementation CustomMoviePlayerViewController

/*---------------------------------------------------------------------------
 *  Assumes file is already downloaded.
 *--------------------------------------------------------------------------*/
- (id)initWithPlay:(Lesson *)_play chapterIndex:(NSUInteger)chapter
{
	// Initialize and create movie URL
    if (self = [super init])
    {
        lesson = _play;
        [lesson retain];
        
        chapterIndex = chapter;
        movieURL = [NSURL fileURLWithPath:[lesson getChapterLocalPath:chapter]];
        [movieURL retain];
    }
	return self;
}

/*---------------------------------------------------------------------------
 * For 3.2 and 4.x devices
 * For 3.1.x devices see moviePreloadDidFinish:
 *--------------------------------------------------------------------------*/
- (void) moviePlayerLoadStateChanged:(NSNotification*)notification 
{
	// Unless state is unknown, start playback
	if ([mp loadState] != MPMovieLoadStateUnknown)
    {
        // Remove observer
        [[NSNotificationCenter 	defaultCenter] 
         removeObserver:self
         name:MPMoviePlayerLoadStateDidChangeNotification 
         object:nil];
        
        // When tapping movie, status bar will appear, it shows up
        // in portrait mode by default. Set orientation to landscape
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
        
		// Rotate the view for landscape playback
        [[self view] setBounds:CGRectMake(0, 0, 480, 320)];
		[[self view] setCenter:CGPointMake(160, 240)];
		[[self view] setTransform:CGAffineTransformMakeRotation(M_PI / 2)]; 
        
		// Set frame of movieplayer
		[[mp view] setFrame:CGRectMake(0, 0, 480, 320)];
        
        // Add movie player as subview
        [[self view] addSubview:[mp view]];   
        
        // Set up tracker.
		[self->lesson startTracker:chapterIndex];
        
		// Play the movie
		[mp play];
	}
}

- (void) finishAndPlayNextLesson:(NSNotification*)notification atChapter:(NSInteger)nextChapter {
    [self->lesson stopTracker];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
 	// Remove observer
    [[NSNotificationCenter 	defaultCenter] 
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification 
     object:nil];
    
    //play next movie
    NSDictionary *userInfo = [notification userInfo];
    
    if ([[userInfo objectForKey:@"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] intValue] ==MPMovieFinishReasonPlaybackEnded && nextChapter != -1)
    {
        chapterIndex = nextChapter;
        movieURL = [NSURL fileURLWithPath:[lesson getChapterLocalPath:chapterIndex]];
        [movieURL retain];
        [self readyPlayer];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }    
}

/*---------------------------------------------------------------------------
 * 
 *--------------------------------------------------------------------------*/
- (void) moviePlayBackDidFinish:(NSNotification*)notification 
{    
    NSInteger nextChapter = [lesson indexOfNextDownloadedLesson:chapterIndex];
    [self finishAndPlayNextLesson:notification atChapter:nextChapter];
}
     
- (void) moviePlayerPlaybackStateDidChange:(NSNotification*)notification {
    return;
/*    
    goal here was to make fast forward and backward buttons go back 
    and forth through the videos, but that is creating some weird bugs
    where video keeps pausing, so better to leave if as is where if
    the user presses and holds, then they advance within the video.
 
    if( [mp playbackState] == MPMoviePlaybackStateSeekingForward ) {
        
        // Remove observer
        [[NSNotificationCenter 	defaultCenter] 
         removeObserver:self
         name:MPMoviePlayerPlaybackStateDidChangeNotification 
         object:nil];
        
        [self moviePlayBackDidFinish:notification];
    } else if( [mp playbackState] == MPMoviePlaybackStateSeekingBackward ) {
        
        // Remove observer
        [[NSNotificationCenter 	defaultCenter] 
         removeObserver:self
         name:MPMoviePlayerPlaybackStateDidChangeNotification 
         object:nil];
        
        NSInteger previousChapter = [lesson canPlayPreviousLesson:chapterIndex];
        [self finishAndPlayNextLesson:notification atChapter:previousChapter];
    }
 */
}

/*---------------------------------------------------------------------------
 *
 *--------------------------------------------------------------------------*/
- (void) readyPlayer
{
    if(mp)
    {
        [mp release];
    }
    mp =  [[MPMoviePlayerController alloc] initWithContentURL:movieURL];
    
    if ([mp respondsToSelector:@selector(loadState)]) 
    {
        // Set movie player layout
        [mp setControlStyle:MPMovieControlStyleFullscreen];
        [mp setFullscreen:YES];
        mp.useApplicationAudioSession = NO;
        
		// May help to reduce latency
		[mp prepareToPlay];
        
		// Register that the load state changed (movie is ready)
		[[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(moviePlayerLoadStateChanged:) 
                                                     name:MPMoviePlayerLoadStateDidChangeNotification 
                                                   object:nil];
    }  
    
    // Register to receive a notification when the movie has finished playing. 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayBackDidFinish:) 
                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
                                               object:nil];

    // Register to receive a notification when the user presses a button. 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(moviePlayerPlaybackStateDidChange:) 
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification 
                                               object:nil];
}

/*---------------------------------------------------------------------------
 * 
 *--------------------------------------------------------------------------*/
- (void) loadView
{
    [self setView:[[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease]];
	[[self view] setBackgroundColor:[UIColor blackColor]];
}

/*---------------------------------------------------------------------------
 *  
 *--------------------------------------------------------------------------*/
- (void)dealloc 
{
	[mp release];
    [movieURL release];
    [lesson release];
	[super dealloc];
}

@end
