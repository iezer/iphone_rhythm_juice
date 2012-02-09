//
//  Chapter.m
//  SimpleDrillDown
//
//  Created by  on 12-01-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Chapter.h"

@implementation Chapter

@synthesize title, remotePath, localPath, filename, isDownloadInProgress;

-(Chapter *)init:(NSString *)_title remotePath:(NSString*)_remotePath localPath:(NSString*)_localPath;
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
            
        }
        return self;
}

@end
