//
//  Chapter.h
//  SimpleDrillDown
//
//  Created by  on 12-01-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chapter : NSObject {
    NSString *title;
    NSString *remotePath;
    NSString *localPath;
    NSString *filename;
    NSString *channel;
    Boolean  isDownloadInProgress;
    UIProgressView *progessView;
}

- (Chapter*)init:(NSString*)_title remotePath:(NSString*)_remotePath localPath:(NSString*)_localPath channel:(NSString*)_channel;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSString *remotePath;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *channel;
@property (nonatomic) Boolean isDownloadInProgress;
@property (nonatomic, retain) UIProgressView *progressView;

@end