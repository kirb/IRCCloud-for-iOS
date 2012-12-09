//
//  ICNotification.m
//  IRCCloud
//
//  Created by Adam D on 17/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import "ICNotification.h"
#import "ICAppDelegate.h"

@implementation ICNotification

+(void)notificationWithMessage:(NSString *)message type:(AJNotificationType)type {
	[AJNotificationView showNoticeInView:((ICAppDelegate *)[UIApplication sharedApplication].delegate).notificationView type:type title:message linedBackground:AJLinedBackgroundTypeStatic hideAfter:4.f];
}

@end
