/*
     File: DataController.h
 Abstract: A simple controller class responsible for managing the application's data.
 Typically this object would be able to load and save a file containing the appliction's data. This example illustrates just the basic minimum: it creates an array containing information about some plays and provides simple accessor methods for the array and its contents.
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

@class Lesson;
@class User;
@class ListOfLessons;

@interface DataController : NSObject {
    User* user;
    NSOperationQueue* videoDownloadQueue;
    Boolean gotLatestSettings;
}

@property (retain) User *user; //atomic
@property (nonatomic, retain) NSOperationQueue* videoDownloadQueue;
@property (nonatomic) Boolean gotLatestSettings;


//- (Lesson *)objectInListAtIndex:(unsigned)theIndex;

- (id)init;
- (Boolean)createDataFromRequest:(NSDictionary *)data;

- (Boolean)canWatchLesson:(Lesson*)lesson chapter:(NSInteger)chapter_index;
- (NSInteger)numberOfDownloadedLessons;
- (Boolean)canWatchChapterInChannel:(Lesson*)lesson chapter:(NSInteger)chapter_index;

- (NSInteger) allowedDownloads; // -1 means unlimited

- (Boolean)expired:(Lesson*)lesson;
- (Boolean)isFreeVideo:(Lesson*)lesson chapter:(NSInteger)chapter_index;
+ (User*)createUserFromData:(NSDictionary *)data;

- (void)deleteAllLessons:(ListOfLessons *)list;
- (Boolean)downloadAllLessons:(ListOfLessons *)list;
- (Boolean)queueAllChapters:(Lesson *)lesson;
- (Boolean)queueChapterDownload:(Lesson *) lesson chapter:(NSUInteger)chapter_index;
- (NSSet*) allChapterTitles;
- (Boolean)validateChapterPlayOrDownload:(Lesson*)lesson chapter:(NSUInteger)chapter_index;
- (Boolean) isDownloadInProgress:(ListOfLessons *)list;
- (void) cancelAllDownloads:(ListOfLessons *)list;

@end
