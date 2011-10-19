//
//  CustomMoviePlayerViewController.h
//
//  Copyright iOSDeveloperTips.com All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface CustomMoviePlayerViewController : UIViewController 
{
  MPMoviePlayerController *mp;
  NSURL 									*movieURL;
}

- (id)initWithPath:(NSString *)moviePath;
- (id)initWithURL:(NSURL *)_movieURL;
- (void)readyPlayer;

@end
