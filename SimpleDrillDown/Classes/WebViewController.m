//
//  webViewController.m
//  
//
//
//  Created by Pierre Addoum on 2/17/10.
//  Copyright 2010. All rights reserved.
//

#import "webViewController.h"
#import "SimpleDrillDownAppDelegate.h"

#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }

@implementation WebViewController

@synthesize _url, _appDelegate;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURLPassed:(NSString *)initURL withDelegate:(SimpleDrillDownAppDelegate*)d {
	if (self = [super init]) {
        self._url = initURL;
        [self openURL:[NSURL URLWithString:initURL]];
        self.hidesBottomBarWhenPushed = NO; //YES
        self._appDelegate = d;
	}
	return self;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)backAction {
	[_webView goBack];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)forwardAction {
	[_webView goForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refreshAction {
	[_webView reload];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopAction {
	[_webView stopLoading];
}

- (void)leaveBrowserAction {
   // [self._appDelegate.tabBarController ];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)shareAction {
	UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:@"" delegate:self
											   cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
											   otherButtonTitles:@"Open in Safari", nil] autorelease];
	[sheet showInView:self.view];
}



- (void)dealloc {
    [super dealloc];
	RELEASE_SAFELY(_loadingURL);
	RELEASE_SAFELY(_webView);
	RELEASE_SAFELY(_toolbar);
	RELEASE_SAFELY(_backButton);
	RELEASE_SAFELY(_forwardButton);
	RELEASE_SAFELY(_refreshButton);
	RELEASE_SAFELY(_stopButton);
	RELEASE_SAFELY(_activityItem);
    RELEASE_SAFELY(_leaveBrowser)
    
}

- (void)loadView {  
	[super loadView];
	////WEBVIEW////////////////////
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,320,420)];
	_webView.delegate = self;
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth
	| UIViewAutoresizingFlexibleHeight;
	_webView.scalesPageToFit = YES;
	[self.view addSubview:_webView];
	
	////SPINNER///////////////////
	
	UIActivityIndicatorView* spinner = [[[UIActivityIndicatorView alloc]
										 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
	[spinner startAnimating];
	
	////Button///////////////////
	_activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
	
	_backButton = [[UIBarButtonItem alloc] initWithImage:
                   [UIImage imageNamed:@"backIcon.png"]
												   style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
	_backButton.tag = 2;
	_backButton.enabled = NO;
	_forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forwardIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardAction)];
	_forwardButton.tag = 1;
	_forwardButton.enabled = NO;
	_refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
					  UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
	_refreshButton.tag = 3;
	_stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:
				   UIBarButtonSystemItemStop target:self action:@selector(stopAction)];
	_stopButton.tag = 3;
    
	_leaveBrowser = [[UIBarButtonItem alloc] initWithImage:
                   [UIImage imageNamed:@"backIcon.png"]
												   style:UIBarButtonItemStylePlain target:self action:@selector(leaveBrowserAction)];
	_leaveBrowser.title = @"RJ App";
    _leaveBrowser.tag = 4;
	_leaveBrowser.enabled = YES;
    
    
    //self.navigationItem.leftBarButtonItem =_leaveBrowser;
    
    
	UIBarButtonItem* actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
									  UIBarButtonSystemItemAction target:self action:@selector(shareAction)] autorelease];
	
	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	
	_toolbar = [[UIToolbar alloc] initWithFrame:
				CGRectMake(0, 460 - 44, 320, 44)];
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
	_toolbar.tintColor = [UIColor blackColor];
	_toolbar.items = [NSArray arrayWithObjects:
					  _backButton, space, _forwardButton, space, _refreshButton, space, actionButton, nil];
	
	
	[self.view addSubview:_toolbar];
    
    //[self openURL:[NSURL URLWithString:_url]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidUnload {
	[super viewDidUnload];
    
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
    [self openURL:[NSURL URLWithString:_url]];
	[super viewWillAppear:animated];
    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewWillDisappear:(BOOL)animated {
	// If the browser launched the media player, it steals the key window and never gives it
	// back, so this is a way to try and fix that
	[self.view.window makeKeyWindow];
	
	[super viewWillDisappear:animated];
	_webView.delegate = nil;
	
	
}

#pragma mark -
#pragma mark UIWebViewDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
	RELEASE_SAFELY(_loadingURL);
	_loadingURL = [request.URL retain];
	_backButton.enabled = [_webView canGoBack];
	_forwardButton.enabled = [_webView canGoForward];
	return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidStartLoad:(UIWebView*)webView {
	//self.title = @"Loading...";
	if (!self.navigationItem.rightBarButtonItem) {
		[self.navigationItem setRightBarButtonItem:_activityItem animated:YES];
	}
    
	UIBarButtonItem* actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
									  UIBarButtonSystemItemAction target:self action:@selector(shareAction)] autorelease];
	
	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	_toolbar.items = [NSArray arrayWithObjects:
					  _backButton, space, _forwardButton, space, _stopButton, space, actionButton, nil];
    
	_backButton.enabled = [_webView canGoBack];
	_forwardButton.enabled = [_webView canGoForward];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webViewDidFinishLoad:(UIWebView*)webView {
	RELEASE_SAFELY(_loadingURL);
	
	//self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	if (self.navigationItem.rightBarButtonItem == _activityItem) {
		[self.navigationItem setRightBarButtonItem:nil animated:YES];
	}
    
	UIBarButtonItem* actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
									  UIBarButtonSystemItemAction target:self action:@selector(shareAction)] autorelease];
	
	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:
						 UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
	_toolbar.items = [NSArray arrayWithObjects:
					  _backButton, space, _forwardButton, space, _refreshButton, space, actionButton, nil];
    
	
	_backButton.enabled = [_webView canGoBack];
	_forwardButton.enabled = [_webView canGoForward];    
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
	RELEASE_SAFELY(_loadingURL);
	[self webViewDidFinishLoad:webView];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIActionSheetDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[[UIApplication sharedApplication] openURL:self.URL];
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURL*)URL {
	return _loadingURL ? _loadingURL : _webView.request.URL;
}



///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openURL:(NSURL*)URL {
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
	[self openRequest:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openRequest:(NSURLRequest*)request {
	[_webView loadRequest:request];
}

- (void)leaveBrowser {
   // [self.delegate.tabBarController
}


@end


