//
//  UINavigationController+KeyboardDismiss.m
//  IRCCloud
//
//  Created by Adam D on 24/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import "UINavigationController+KeyboardDismiss.h"

@implementation UINavigationController (KeyboardDismiss)

- (BOOL)disablesAutomaticKeyboardDismissal
{
	//why couldn't this "feature" be optional instead? :(
	return NO;
}

@end
