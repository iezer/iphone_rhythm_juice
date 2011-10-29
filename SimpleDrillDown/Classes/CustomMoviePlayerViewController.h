//
//  CustomMoviePlayerViewController.h
//
//  Copyright iOSDeveloperTips.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Lesson.h"

@interface CustomMoviePlayerViewController : UIViewController 
{
    MPMoviePlayerController *mp;
    NSURL *movieURL;
    Lesson *play;
    NSInteger chapterIndex;
}

- (id)initWithPlay:(Lesson *)_play chapterIndex:(NSUInteger)chapter;
- (void)readyPlayer;

@end
