//
//  webViewController.h
//  
//
//
//  Created by Pierre Addoum on 2/17/10.
//  Copyright 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface webViewController : UIViewController<UIWebViewDelegate,UIActionSheetDelegate> {
	
	UIWebView* _webView;
	UIToolbar* _toolbar;
	UIBarButtonItem* _backButton;
	UIBarButtonItem* _forwardButton;
	UIBarButtonItem* _refreshButton;
	UIBarButtonItem* _stopButton;
	UIBarButtonItem* _activityItem;
	NSURL* _loadingURL;
    
}

@property(nonatomic,readonly) NSURL* URL;

- (id)initWithURLPassed:(NSString *)initURL;
- (void)openURL:(NSURL*)URL;
- (void)openRequest:(NSURLRequest*)request;

@end

