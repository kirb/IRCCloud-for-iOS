//
//  ICNetwork.h
//  IRCCloud
//
//  Created by Aditya KD on 21/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ICChannel, ICNetwork;

@protocol ICNetworkDelegate <NSObject>
@optional
- (void)network:(ICNetwork *)network didAddChannel:(ICChannel *)channel;
- (void)network:(ICNetwork *)network willRemoveChannel:(ICChannel *)channel;
- (void)network:(ICNetwork *)network didRemoveChannel:(ICChannel *)channel;

- (void)network:(ICNetwork *)network didChangeStatus:(NSString *)oldStatus toStatus:(NSString *)newStatus;
- (void)network:(ICNetwork *)network disconnectedUnexpectedlyWithInfo:(NSDictionary *)info;
@end

@interface ICNetwork : NSObject
{
    __weak id<ICNetworkDelegate> _delegate;
}

@property (nonatomic, copy) NSString *networkName;
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, assign, getter = isSSL) BOOL SSL;
@property (nonatomic, copy) NSNumber *port;
@property (nonatomic, copy) NSNumber *cid;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSNumber *connectionLag; // lag in µs.

@property (nonatomic, weak) id delegate;

- (id)initWithNetworkNamed:(NSString *)networkName hostName:(NSString *)hostName SSL:(BOOL)isSSL port:(NSNumber *)port connectionID:(NSNumber *)cid;
- (void)addOOBChannelFromDictionary:(NSDictionary *)dict;
- (void)addChannelFromDictionary:(NSDictionary *)dict;
- (NSArray *)channels;
- (void)removeChannelWithBID:(NSNumber *)channel;
- (void)userPartedChannelWithBID:(NSNumber *)bid;
- (void)disconnectedUnexepectedlyWithFailInfo:(NSDictionary *)info;

- (ICChannel *)channelWithBID:(NSNumber *)bid;

@end
