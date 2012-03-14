//
//  webViewController.h
//  
//
//
//  Created by Pierre Addoum on 2/17/10.
//  Copyright 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimpleDrillDownAppDelegate;

@interface WebViewController : UIViewController<UIWebViewDelegate,UIActionSheetDelegate> {
	
	UIWebView* _webView;
	UIToolbar* _toolbar;
	UIBarButtonItem* _backButton;
	UIBarButtonItem* _forwardButton;
	UIBarButtonItem* _refreshButton;
	UIBarButtonItem* _stopButton;
	UIBarButtonItem* _activityItem;
    UIBarButtonItem* _leaveBrowser;
	NSURL* _loadingURL;
    NSString* _url;
    SimpleDrillDownAppDelegate* _appDelegate;
    
}

@property(nonatomic,readonly) NSURL* URL;
@property(nonatomic,retain) NSString* _url;
@property(nonatomic,retain) SimpleDrillDownAppDelegate* _appDelegate;

- (id)initWithURLPassed:(NSString *)initURL withDelegate:(SimpleDrillDownAppDelegate*)d;
- (void)openURL:(NSURL*)URL;
- (void)openRequest:(NSURLRequest*)request;

@end

