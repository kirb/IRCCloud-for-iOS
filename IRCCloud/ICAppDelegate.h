//
//  ICAppDelegate.h
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICWebSocketDelegate.h"
#import "ICBufferViewController.h"
#import "ICMasterViewController.h"

@interface ICAppDelegate : UIResponder <UIApplicationDelegate> {
	UIView *notificationView;
	ICWebSocketDelegate *webSocket;
	ICMasterViewController *buffers;
	ICBufferViewController *currentBuffer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *notificationView;
@property (strong, nonatomic) ICWebSocketDelegate *webSocket;
@property (strong, nonatomic) ICMasterViewController *buffers;
@property (strong, nonatomic) ICBufferViewController *currentBuffer;

@end
