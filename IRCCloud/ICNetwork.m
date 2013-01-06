//
//  ICNetwork.m
//  IRCCloud
//
//  Created by Aditya KD on 21/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import "ICNetwork.h"
#import "ICChannel.h"
#import "ICAppDelegate.h"
#import "ICWebSocketDelegate.h"
#import "ICParser.h"

@implementation ICNetwork
{
    NSMutableDictionary *_channels;
    NSMutableArray      *_notices;
}

#pragma mark Basic Settings -
- (id)initWithNetworkNamed:(NSString *)networkName hostName:(NSString *)hostName SSL:(BOOL)isSSL port:(NSNumber *)port connectionID:(NSNumber *)cid
{
    self = [super init];
    if (self) {
        _networkName = networkName;
        _hostName    = hostName;
        _SSL         = isSSL;
        _port        = port;
        _cid         = cid;
        
        _channels = [[NSMutableDictionary alloc] init];
        _notices  = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)description
{
    return [NSString stringWithFormat:@"%@ Network name: %@ Port: %@, SSL: %@, CID: %@", [super description], self.networkName, self.port, ((self.isSSL) ? @"ON":@"OFF"), self.cid];
}

#pragma mark Network Management -
- (void)setStatus:(NSString *)status
{
    if ([self.delegate respondsToSelector:@selector(network:didChangeStatus:)]) {
        [self.delegate network:self didChangeStatus:_status toStatus:status];
    }
    _status = status;
}

- (void)disconnectedUnexepectedlyWithFailInfo:(NSDictionary *)info
{
    if ([self.delegate respondsToSelector:@selector(network:disconnectedUnexpectedlyWithInfo:)]) {
        [self.delegate network:self disconnectedUnexpectedlyWithInfo:info];
    }
}

#pragma mark Channel Management -
- (void)addOOBChannelFromDictionary:(NSDictionary *)dict
{
    ICChannel *channel   = [[ICChannel alloc] initWithName:dict[@"name"] andBufferID:dict[@"bid"]];
    channel.cid          = dict[@"cid"];
    channel.creationDate = dict[@"created"];
    _channels[channel.bid] = channel;
}

- (void)addChannelFromDictionary:(NSDictionary *)dict
{
    __strong ICChannel *channel = _channels[dict[@"bid"]];
    if (!channel) {
        channel = [[ICChannel alloc] initWithName:dict[@"chan"] andBufferID:dict[@"bid"]];
        channel.cid          = dict [@"cid"];
        channel.creationDate = dict[@"created"];
    }
    channel.members      = dict[@"members"];
    channel.topic        = dict[@"topic"];
    channel.type         = dict[@"channel_type"];
    channel.mode         = dict[@"mode"];
    channel.ops          = dict[@"ops"];
    
    if (!_channels[channel.bid])
        _channels[channel.bid] = channel;
    if ([_delegate respondsToSelector:@selector(network:didAddChannel:)])
        [self.delegate network:self didAddChannel:channel];
}

- (void)removeChannelWithBID:(NSNumber *)bid
{
    if (!_channels[@"bid"]) // the channel has been removed already.
        return;

    if ([_delegate respondsToSelector:@selector(network:willRemoveChannel:)])
        [self.delegate network:self willRemoveChannel:_channels[bid]];

    [_channels removeObjectForKey:bid];

    if ([_delegate respondsToSelector:@selector(network:didRemoveChannel:)])
        [self.delegate network:self didRemoveChannel:_channels[bid]];
}

// called when the user uses the app to part.
- (void)userPartedChannelWithBID:(NSNumber *)bid
{
    NSDictionary *removalDict = @{@"reqid"   : @(rand()),
                                  @"_method" : @"part",
                                  @"cid"     : [(ICChannel *)_channels[bid] cid],
                                  @"channel" : [(ICChannel *)_channels[bid] name],
                                  @"msg"     : @"IRCCloud app for iOS"};
    [[(ICAppDelegate *)[UIApplication sharedApplication].delegate webSocket] sendJSONFromDictionary:removalDict];
    [_channels removeObjectForKey:bid];
}

- (NSArray *)channels
{
    return [[_channels allValues] sortedArrayUsingComparator:^NSComparisonResult(id channel1, id channel2) {
        return [((ICChannel*) channel1).name caseInsensitiveCompare:((ICChannel*) channel2).name];
    }];
}

- (ICChannel *)channelWithBID:(NSNumber *)bid
{
    // get the appropriate key from the dict.
    /*
    NSNumber *requiredKey = nil;
    for (NSNumber *key in [_channels allKeys]) {
        if (key.intValue == bid.intValue) {
            requiredKey = key;
        }
    }
    return [_channels objectForKey:requiredKey];
     */
    return _channels[bid];
}

#pragma mark Notice Management -
- (void)addNotice:(NSDictionary *)notice
{
    [_notices addObject:notice];
}

@end

