//
//  CustomMoviePlayerViewController.h
//
//  Copyright iOSDeveloperTips.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Play.h"

@interface CustomMoviePlayerViewController : UIViewController 
{
    MPMoviePlayerController *mp;
    NSURL *movieURL;
    Play *play;
    NSInteger chapterIndex;
}

- (id)initWithPlay:(Play *)_play chapterIndex:(NSUInteger)chapter;
- (id)initWithPath:(NSString *)moviePath play:(Play *)_play;
- (id)initWithURL:(NSURL *)_movieURL play:(Play *)_play;
- (void)readyPlayer;

@end
