//
//  ICController.h
//  IRCCloud
//
//  Created by Aditya KD on 21/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ICNetwork;

@interface ICController : NSObject
{
}

+ (ICController *)sharedController;
- (void)addNetwork:(ICNetwork *)connection;
- (void)removeNetwork:(ICNetwork *)connection;
- (ICNetwork *)networkForConnection:(NSNumber *)connectionID;

@end
