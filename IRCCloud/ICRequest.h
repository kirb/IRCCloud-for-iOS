//
//  ICRequest.h
//  IRCCloud
//
//  Created by Adam D on 14/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICRequest : NSObject
{
	id delegate;
	SEL selector;
}

+ (ICRequest *)requestWithPage:(NSString *)page parameters:(NSString *)params unauth:(BOOL)unauth delegate:(id)delegate selector:(SEL)selector;
+ (ICRequest *)requestWithPage:(NSString *)page parameters:(NSString *)params delegate:(id)delegate selector:(SEL)selector;

@end
