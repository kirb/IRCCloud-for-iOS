//
//  ICNetwork.m
//  IRCCloud
//
//  Created by Aditya KD on 21/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICNetwork.h"
#import "ICChannel.h"

@implementation ICNetwork
{
    NSMutableDictionary *_channels;
}

#pragma mark Basic Settings -
- (id)initWithNetworkNamed:(NSString *)networkName hostName:(NSString *)hostName SSL:(BOOL)isSSL port:(NSNumber *)port connectionID:(NSNumber *)cid
{
    self = [super init];
    if (self){
        _networkName = [networkName copy];
        _hostName = [hostName copy];
        _SSL        = isSSL;
        _port     = port;
        _cid      = cid;
        _channels = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)description
{
    return [NSString stringWithFormat:@"Network name: %@ Port: %@, SSL: %@, CID: %@", self.networkName, self.port, ((self.isSSL) ? @"ON":@"OFF"), self.cid];
}

#pragma mark Channel Management -
- (void)addChannelsFromArray:(NSArray *)array
{
    for (ICChannel *channel in array) {
        for (ICChannel *currentChan in _channels) {
            if ([channel.name isEqualToString:currentChan.name])
                break;
            else
                [_channels setObject:channel forKey:channel.cid];
        }
    }
}


- (void)addChannelFromDictionary:(NSDictionary *)dict
{
    ICChannel *channel   = [[ICChannel alloc] initWithName:dict[@"chan"] andBufferID:dict[@"bid"]];
    channel.members      = dict[@"members"];
    channel.creationDate = dict[@"created"];
    channel.topic        = dict[@"topic"];
    channel.type         = dict[@"channel_type"];
    channel.mode         = dict[@"mode"];
    channel.ops          = dict[@"ops"];
    if (_delegate)
        [self.delegate network:self didAddChannel:channel];
    [_channels setObject:channel forKey:channel.bid];
}



- (void)addChannel:(ICChannel *)channel
{
    [_channels setObject:channel forKey:channel.bid];
    if (_delegate)
        [self.delegate network:self didAddChannel:channel];
    NSLog(@"%@", _channels);
}

- (void)removeChannelWithBID:(NSNumber *)bid
{
    if (_delegate)
        [self.delegate network:self didRemoveChannel:[_channels objectForKey:bid]];
    [_channels removeObjectForKey:bid];
}

- (NSArray *)channels
{
    return [_channels allValues];
}

@end

