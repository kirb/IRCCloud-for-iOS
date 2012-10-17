//
//  ICNotification.h
//  IRCCloud
//
//  Created by Adam D on 17/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AJNotificationView.h"

@interface ICNotification : NSObject
+(void)notificationWithMessage:(NSString *)message type:(AJNotificationType)type;
@end
