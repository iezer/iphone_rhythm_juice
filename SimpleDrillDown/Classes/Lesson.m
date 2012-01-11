                /*
 File: Play.m
 Abstract: A simple class to represent information about a play.
 Version: 2.7
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */

#import "Lesson.h"
#import "ASIHTTPRequest.h"
#import "Chapter.h"

@implementation Lesson

@synthesize title, instructors, chapters, tracker, premium, lessonFolderPath, detailViewController;

- (Lesson*)init:(NSString*)_title instructors:(NSArray*)_instructors chapters:(NSArray*)_chapters chapterTitles:(NSArray*)_chapterTitles premium:(Boolean)_premium {
    self = [super init];
    if (self != nil)
    {
        self.title = _title;
        self.instructors = _instructors;
        self.premium = _premium;
        self.tracker = [[TimeTracker alloc] init];
        
        NSFileManager *     fileManager;
        fileManager = [NSFileManager defaultManager];
        assert(fileManager != nil);
        
        NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *lessons_folder_path = [document_folder_path stringByAppendingPathComponent:@"lessons"]; 
        
        self.lessonFolderPath = [lessons_folder_path stringByAppendingPathComponent:self.title];
        
        self->chapters = [[[NSMutableArray alloc] init] retain];
        
        NSInteger chapterCount = MIN( [_chapters count], [_chapterTitles count] );
        for (int i = 0; i < chapterCount; i ++) {
            NSString* remotePath = [_chapters objectAtIndex:i];
            [self->chapters addObject:[[Chapter alloc] init:[_chapterTitles objectAtIndex:i] remotePath:remotePath localPath:[self createChapterLocalPath:remotePath]]];
        }
        
    }
    return self;
}

-(void)startTracker:(NSUInteger)chapter {
	[self.tracker play:[self getChapterTitle:chapter]];
}

-(void)stopTracker {
	[self.tracker stop];
}

- (void)dealloc {
	[title release];
	[instructors release];
	[chapters release];
	[tracker release];
    [lessonFolderPath release];
	[super dealloc];
}

- (NSString*)createChapterLocalPath:(NSString*)chapterRemotePath
{
    NSURL* chapter_remote_url = [NSURL URLWithString:chapterRemotePath];
    
    NSString* filename = [chapter_remote_url lastPathComponent];
    NSString* chapter_local_path = [lessonFolderPath stringByAppendingPathComponent:filename];
    return chapter_local_path;
}

- (NSString*)getChapterLocalPath:(NSInteger)chapter
{
    return [[self->chapters objectAtIndex:chapter] localPath];
}

- (NSString*)getChapterRemotePath:(NSInteger)chapter
{
    return [[self->chapters objectAtIndex:chapter] remotePath];
}

- (NSString*)getChapterTitle:(NSInteger)chapter
{
    return [[self->chapters objectAtIndex:chapter] title];
}

- (Boolean)isChapterDownloadInProgress:(NSInteger)chapter
{
    return [[self->chapters objectAtIndex:chapter] isDownloadInProgress];
}


- (void)setChapterDownloadInProgressFlag:(NSInteger)chapter withFlag:(Boolean)flag
{
    Chapter *c = [[self chapters] objectAtIndex:chapter] ;
    [c setIsDownloadInProgress: flag];
}

- (Boolean) isDownloadedLocally
{
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    BOOL isDir;
    BOOL directoryExists = [fileManager fileExistsAtPath:lessonFolderPath isDirectory:&isDir] && isDir;

    //NSError *error;
    //BOOL nonEmpty = [[fileManager contentsOfDirectoryAtPath:lessonFolderPath error:&error] count] > 0;
    
    return directoryExists;// && nonEmpty;
}

- (NSString*) status:(NSInteger)chapter
{
    if ([self isChapterDownloadedLocally:chapter]) {
        return @"downloaded";
    } else if ([self isChapterDownloadInProgress:chapter]) {
        return @"downloading...";
    } else {
        return @"not downloaded.";
    }
}

- (Boolean) isChapterDownloadedLocally:(NSUInteger)chapter
{
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    NSString* chapter_local_path = [self getChapterLocalPath:chapter];
    NSLog(@"%@", chapter_local_path);
    return [fileManager fileExistsAtPath:chapter_local_path];
}

- (void)deleteFiles
{    
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSError *error;
    if ( [self isDownloadedLocally] ) {
        [fileManager removeItemAtPath:lessonFolderPath error:&error];
        // call 2nd time to delete empty directory.
        [fileManager removeItemAtPath:lessonFolderPath error:&error];
    }
}

- (void)queueAllChapters
{
    for (int i = 0; i < [chapters count]; i++) {
        if (![self isChapterDownloadedLocally:i] && ![self isChapterDownloadInProgress:i]) {
            [self queueChapterDownload:i];
        }
    }
}

- (void)queueChapterDownload:(NSUInteger)chapter {
    
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString* chapter_remote_path = [self getChapterRemotePath:chapter];
    NSURL* chapter_remote_url = [NSURL URLWithString:chapter_remote_path];
    
    NSError *error;
    if ( ! [self isDownloadedLocally] ) {
        [[NSFileManager defaultManager] createDirectoryAtURL: [NSURL fileURLWithPath:lessonFolderPath] withIntermediateDirectories:true attributes:nil error:&error];
    }
    
    if ( ! [self isChapterDownloadedLocally:chapter]) {
        [self setChapterDownloadInProgressFlag:chapter withFlag:true];
         ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:chapter_remote_url];
        [request setDelegate:self];
        [request startAsynchronous];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    
    for (int i = 0; i < [chapters count]; i++) {
        NSString* chapter_local_path = [self getChapterLocalPath:i];
        NSString* chapter_remote_path = [self getChapterRemotePath:i];
        NSURL* chapter_remote_url = [NSURL URLWithString:chapter_remote_path];
        if ([chapter_remote_url isEqual:[request originalURL]]) {
            BOOL written = [responseData writeToFile:chapter_local_path atomically:NO];
            if (written)
                NSLog(@"Saved to file: %@", chapter_local_path);
            [self setChapterDownloadInProgressFlag:i withFlag:false];
        }
    }
    
    if ( detailViewController != nil) {
        [detailViewController.tableView reloadData];
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    NSLog(@"Connection Error: %@", error);
    
    for (int i = 0; i < [chapters count]; i++) {
        NSString* chapter_remote_path = [self getChapterRemotePath:i];
        NSURL* chapter_remote_url = [NSURL URLWithString:chapter_remote_path];
        if ([chapter_remote_url isEqual:[request originalURL]]) {
            [self setChapterDownloadInProgressFlag:i withFlag:false];
        }
    }
    
    if ( detailViewController != nil) {
        [detailViewController.tableView reloadData];
    }
}


/* Return the chapter index of the next downloaded chapter, or -1 if there is nothing left. */
- (NSInteger) canPlayNextLesson:(NSInteger)currentChapterIndex
{
    for (NSInteger i = currentChapterIndex + 1; i < [chapters count]; i++ ) {
        if ( [self isChapterDownloadedLocally:(i)] )
        {
            return i;
        }
    }
    return -1;
}
@end
