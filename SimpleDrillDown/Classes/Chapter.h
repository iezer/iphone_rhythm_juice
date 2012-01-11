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
    Boolean  isDownloadInProgress;
}


- (Chapter*)init:(NSString*)_title remotePath:(NSString*)_remotePath localPath:(NSString*)_localPath;


@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *localPath;
@property (nonatomic, retain) NSString *remotePath;
@property (nonatomic) Boolean isDownloadInProgress;

- (NSString*) getFilename;

@end