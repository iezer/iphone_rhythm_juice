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
    Boolean  isDownloadInProgress;
}


- (Chapter*)init:(NSString*)_title remotePath:(NSString*)_remotePath localPath:(NSString*)_localPath;


@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSString *remotePath;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic) Boolean isDownloadInProgress;

@end