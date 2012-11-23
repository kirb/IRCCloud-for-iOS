//
//  ICNetwork.h
//  IRCCloud
//
//  Created by Aditya KD on 21/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ICChannel, ICConversation;

@interface ICNetwork : NSObject

@property (nonatomic, copy) NSString *networkName;
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, assign, getter = isSSL) BOOL SSL;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) int cid;
@property (nonatomic, copy) NSString *status;

- (id)initWithNetworkNamed:(NSString *)networkName hostName:(NSString *)hostName SSL:(BOOL)isSSL port:(int)port connectionID:(int)cid;

// typically, this should be an array of ICChannel objects, but maybe we could add a -addChannelsCreatingChannelsFromStrings:(NSArray *)array or soemthing method
// might make it easier to load from a plist.

- (void)addChannel:(ICChannel *)channel;
- (void)removeChannel:(ICChannel *)channel;

@end
