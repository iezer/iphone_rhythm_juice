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

@implementation Lesson

@synthesize title, instructors, chapters, chapterTitles, tracker, premium, markedForOfflineViewing;

-(Lesson*)init {
	self.tracker = [[TimeTracker alloc] init];
	return self;
}

-(void)startTracker:(NSUInteger)chapter {
	[self.tracker play:[chapters objectAtIndex:chapter] ];
}

-(void)stopTracker {
	[self.tracker stop];
}

- (void)dealloc {
	[title release];
	[instructors release];
	[chapters release];
	[tracker release];
	[super dealloc];
}

- (NSString*)getLessonFolder
{
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *document_folder_path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *lessons_folder_path = [document_folder_path stringByAppendingPathComponent:@"lessons"]; 
    NSString *this_lesson_folder_path = [lessons_folder_path stringByAppendingPathComponent:self.title];
    
    return this_lesson_folder_path;
}

- (NSString*)getChapterLocalPath:(NSInteger)chapter
{
    NSString* chapter_remote_path = [self.chapters objectAtIndex:chapter];
    NSURL* chapter_remote_url = [NSURL URLWithString:chapter_remote_path];
    
    NSString* filename = [chapter_remote_url lastPathComponent];
    NSString* this_lesson_folder_path = [self getLessonFolder];
    NSString* chapter_local_path = [this_lesson_folder_path stringByAppendingPathComponent:filename];
    return chapter_local_path;
}

- (Boolean) isDownloadedLocally
{
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *this_lesson_folder_path = [self getLessonFolder];
    BOOL isDir;
    return ([fileManager fileExistsAtPath:this_lesson_folder_path isDirectory:&isDir] && isDir);
}


- (Boolean) isChapterDownloadedLocally:(NSUInteger)chapter
{
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    NSString* chapter_local_path = [self getChapterLocalPath:chapter];
    return [fileManager fileExistsAtPath:chapter_local_path];
}

- (void)deleteFiles
{    
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString *this_lesson_folder_path = [self getLessonFolder];
    
    NSError *error;
    if ( [self isDownloadedLocally] ) {
        [[NSFileManager defaultManager] removeItemAtPath:this_lesson_folder_path error:&error];
    }
}
    
- (NSURL*)getMovieFile:(NSUInteger)chapter {
    
    NSFileManager *     fileManager;
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    NSString* chapter_remote_path = [self.chapters objectAtIndex:chapter];
    NSURL* chapter_remote_url = [NSURL URLWithString:chapter_remote_path];
    
    NSString *this_lesson_folder_path = [self getLessonFolder];
    
    NSError *error;
    if ( ! [self isDownloadedLocally] ) {
        [[NSFileManager defaultManager] createDirectoryAtURL: [NSURL fileURLWithPath:this_lesson_folder_path] withIntermediateDirectories:true attributes:nil error:&error];
    }
    
    NSString* chapter_local_path = [self getChapterLocalPath:chapter];
    
    //@TODO maybe should be using NSURLConnectionDownloadDelegate
    
    if ( ! [self isChapterDownloadedLocally:chapter]) {
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setHTTPMethod:@"GET"];
        NSURLResponse *response;
        
        NSData *urlData;
        [request setURL:chapter_remote_url];
        urlData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        BOOL written = [urlData writeToFile:chapter_local_path atomically:NO];
        if (written)
            NSLog(@"Saved to file: %@", chapter_local_path);
    }
    
    return [NSURL fileURLWithPath:chapter_local_path];
}

@end
