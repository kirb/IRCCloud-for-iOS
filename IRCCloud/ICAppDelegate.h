//
//  ICAppDelegate.h
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface ICAppDelegate : UIResponder <UIApplicationDelegate> {
	SRWebSocket *webSocket;
	UIView *notificationView;
}

-(void)openWebSocket;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIView *notificationView;

@end
