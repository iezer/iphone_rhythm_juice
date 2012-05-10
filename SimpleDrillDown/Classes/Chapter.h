//
//  Chapter.h
//  SimpleDrillDown
//
//  Created by  on 12-01-03.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ASIHTTPRequest;
@interface Chapter : NSObject {
    NSString *title;
    NSString *remotePath;
    NSString *localPath;
    NSString *filename;
    ASIHTTPRequest *request;
    NSInteger 
    channel;
    Boolean  isDownloadInProgress;
    UIProgressView *progessView;
}

- (Chapter*)init:(NSString*)_title remotePath:(NSString*)_remotePath localPath:(NSString*)_localPath channel:(NSInteger)_channel;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSString *remotePath;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic) NSInteger channel;
@property (nonatomic) Boolean isDownloadInProgress;
@property (nonatomic, retain) ASIHTTPRequest *request;
@property (nonatomic, retain) UIProgressView *progressView;

@end