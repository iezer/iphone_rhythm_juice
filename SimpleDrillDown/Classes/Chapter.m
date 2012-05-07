//
//  Chapter.m
//  SimpleDrillDown
//
//  Created by  on 12-01-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Chapter.h"

@implementation Chapter

@synthesize title, remotePath, localPath, filename, channel, isDownloadInProgress, progressView;

-(Chapter *)init:(NSString *)_title remotePath:(NSString*)_remotePath localPath:(NSString*)_localPath channel:(NSInteger)_channel
{
        self = [super init];
        if (self != nil)
        {
            self.title = _title;
            self.remotePath = _remotePath;
            self.localPath = _localPath;
            self.isDownloadInProgress = false;
            
            NSURL* chapter_remote_url = [NSURL URLWithString:self.remotePath];
            self.filename = [chapter_remote_url lastPathComponent];
            progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            
            progressView.hidden = true;
            progressView.tag = 1234;
            progressView.frame = CGRectMake(110,30,150,10);
            
            self.channel = _channel;
        }
        return self;
}

/*
-(void)release {
    NSLog(@"I'm released");
    [super release];
}
 */

- (void)dealloc {
	[title release];
	[remotePath release];
	[localPath release];
	[filename release];
    [progressView release];
	[super dealloc];
}

@end
