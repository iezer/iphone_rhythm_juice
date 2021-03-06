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
#import "Chapter.h"
#import "ASIHTTPRequest.h"

@implementation Lesson

@synthesize title, instructors, chapters, tracker, premium, lessonFolderPath, singleLessonViewController;

- (Lesson*)init:(NSString*)_title instructors:(NSArray*)_instructors lessonFolderPath:(NSString*)_lessonFolderPath chapters:(NSMutableArray*)_chapters premium:(Boolean)_premium {
    self = [super init];
    if (self != nil)
    {
        self.title = _title;
        self.instructors = _instructors;
        self.premium = _premium;
        TimeTracker* _tracker = [[TimeTracker alloc] init];
        self.tracker = _tracker;
        [_tracker release];
        
        self.lessonFolderPath = _lessonFolderPath;
        self.chapters = _chapters;
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
    [singleLessonViewController release];
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

- (NSInteger) downloadedChapters {
    NSInteger c = 0;
    
    for (NSInteger i = 0; i < [self count]; i++) {
        if ([self isChapterDownloadedLocally:i]) {
            c++;
        }
    }
    return c;
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

-(NSString*) downloadStatus {
    NSString *message = [[[NSString alloc] initWithFormat:@"%d / %d downloaded", [self downloadedChapters], [self count]] autorelease];
    return message;
}

- (NSString*) status:(NSInteger)chapter
{ 
    Chapter *c = [chapters objectAtIndex:chapter];
    if ([self isChapterDownloadedLocally:chapter]) {
        c.progressView.hidden = true;
        return @"downloaded, click to play";
    } else if ([self isChapterDownloadInProgress:chapter]) {
        c.progressView.hidden = false;
        return @"downloading...";
    } else if ( ![self isVideoTypeSupported:chapter] ) {
        return @"incompatible with iPhone"; 
    } else {
        c.progressView.hidden = true;
        return @"click to download";
    }
}

- (UITableViewCellEditingStyle) getEditingStyle:(NSInteger)chapter {
    if ([self isChapterDownloadedLocally:chapter]) {
        return UITableViewCellEditingStyleDelete;
    } else if ([self isChapterDownloadInProgress:chapter]) {
        return UITableViewCellEditingStyleNone;
    } else {
        return UITableViewCellEditingStyleInsert;
    }
}

- (Boolean) isChapterDownloadedLocally:(NSUInteger)chapter
{
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    NSString* chapter_local_path = [self getChapterLocalPath:chapter];
    //NSLog(@"%@", chapter_local_path);
    return [fileManager fileExistsAtPath:chapter_local_path];
}

- (void)cancelChapterDownload:(NSUInteger)chapter_index {
    Chapter* chapter = [chapters objectAtIndex:chapter_index];
    if (chapter.isDownloadInProgress) {
    [chapter.request cancel];
    [self closeDownloadRequest:chapter_index];
    }
}

- (void)deleteChapter:(NSUInteger)chapter {
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSError *error;
    if ([self isChapterDownloadedLocally:chapter]) {
        [fileManager removeItemAtPath:[self getChapterLocalPath:chapter] error:&error];
    }
}

- (void)cancelAllDownloads {    
    for (NSInteger i = 0; i < [self count]; i++) {
        [self cancelChapterDownload:i];
    }
}

- (void)deleteFiles {    
    for (NSInteger i = 0; i < [self count]; i++) {
        [self deleteChapter:i];
    }
}

- (void)cleanupDirectory {
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSDirectoryEnumerator *dirEnum =
    [fileManager enumeratorAtPath:lessonFolderPath];
    
    NSMutableSet * validChapterNames = [NSMutableSet set];
    for (int i = 0; i < [chapters count]; i++) {
        [validChapterNames addObject:[[chapters objectAtIndex:i] filename]];
    }
    
    NSString *file;
    while (file = [dirEnum nextObject]) {
        
        if ( ![validChapterNames containsObject:file] ) {
            NSError *error;
            [fileManager removeItemAtPath:file error:&error];
        }
    }
}

- (void)closeDownloadRequest:(NSInteger)chapter_index {
    Chapter* chapter = [chapters objectAtIndex:chapter_index];
    chapter.isDownloadInProgress = false;
    if( chapter.request ) {
        chapter.request = nil;
    }
    if ( singleLessonViewController != nil) {
        [singleLessonViewController update];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSData *responseData = [request responseData];
    
    for (int i = 0; i < [chapters count]; i++) {
        NSString* chapter_local_path = [self getChapterLocalPath:i];
        NSString* chapter_remote_path = [self getChapterRemotePath:i];
        NSLog(@"'%@'  '%@'", chapter_remote_path, [[request originalURL] lastPathComponent]);
        if ([chapter_remote_path isEqual:[[request originalURL] lastPathComponent]]) {
            BOOL written = [responseData writeToFile:chapter_local_path atomically:NO];
            if (written)
                NSLog(@"Saved to file: %@", chapter_local_path);
            [self closeDownloadRequest:i];
            break;
        }
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
            [self closeDownloadRequest:i];
        }
    }
}

- (void)setChapterDownloadInProgressFlag:(NSInteger)chapter withFlag:(Boolean)flag
{
    Chapter *c = [[self chapters] objectAtIndex:chapter] ;
    [c setIsDownloadInProgress: flag];
}

/* Return the chapter index of the next downloaded chapter, or -1 if there is nothing left. */
- (NSInteger) indexOfNextDownloadedLesson:(NSInteger)currentChapterIndex
{
    for (NSInteger i = currentChapterIndex + 1; i < [chapters count]; i++ ) {
        if ( [self isChapterDownloadedLocally:(i)] )
        {
            return i;
        }
    }
    return -1;
}

/* Return the chapter index of the previous downloaded chapter, or -1 if there is nothing left. */
- (NSInteger) indexOfPreviousDownloadedLesson:(NSInteger)currentChapterIndex
{
    for (NSInteger i = currentChapterIndex - 1; i >=0; i-- ) {
        if ( [self isChapterDownloadedLocally:(i)] )
        {
            return i;
        }
    }
    return -1;
}

- (BOOL) isVideoTypeSupported:(NSInteger) chapter {
    NSString* path = [self getChapterRemotePath:chapter];
    NSRange r1 = [path rangeOfString:@".flv"];
    NSRange r2 = [path rangeOfString:@".f4v"];
    return r1.location == NSNotFound && r2.location == NSNotFound;
}

-(NSInteger) count {
    return [self->chapters count];
}

-(NSComparisonResult) compare:(Lesson *)otherObject {
    return [self.title compare:otherObject.title];
}

-(NSSet*) chapterTitles {
    
    NSMutableSet * titles = [[NSMutableSet alloc] init];
    for (Chapter* c in chapters) {
        [titles addObject:c.filename];
    }
    NSSet* retSet = [NSSet setWithSet:titles];
    [titles release];
    return retSet;
}

-(Boolean) isDownloadInProgress {    
    for (NSInteger i = 0; i < [self count]; i++) {
        Chapter* chapter = [chapters objectAtIndex:i];
        if (chapter.isDownloadInProgress) {
            return true;
        }
    }
    return false;
}

@end
