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
    NSMutableArray *_channels;
}

#pragma mark Basic Settings -
- (id)initWithNetworkNamed:(NSString *)networkName hostName:(NSString *)hostName SSL:(BOOL)isSSL port:(int)port connectionID:(int)cid
{
    self = [super init];
    if (self){
        _networkName = [networkName copy];
        _hostName = [hostName copy];
        _SSL = isSSL;
        _port = port;
        _cid = cid;
        _channels = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setNetworkName:(NSString *)networkName
{
    if ([networkName isEqualToString:self.networkName])
        return;
    else {
        // make sure the current object is released. Else it will become just a leak that no one has a reference to.
        self.networkName = networkName;
    }
}

- (void)setHostName:(NSString *)hostName
{
    if ([hostName isEqualToString:self.hostName])
        return;
    else {
        self.hostName = hostName;
    }
}

- (id)description
{
    return [NSString stringWithFormat:@"Network name: %@ Port: %@, SSL: %@, CID: %@", self.networkName, [NSNumber numberWithInt:self.port], ((self.isSSL) ? @"on":@"off"), [NSNumber numberWithInt:self.cid]];
}

#pragma mark Channel Management -
- (void)addChannelsFromArray:(NSArray *)array
{
    for (ICChannel *channel in array) {
        for (ICChannel *currentChan in _channels) {
            if ([channel.name isEqualToString:currentChan.name])
                break;
            else
                [_channels addObject:channel];
        }
    }
}

- (void)addChannel:(ICChannel *)channel
{
    for (ICChannel *currentChannel in _channels)
        if ([channel.name isEqualToString:currentChannel.name])
            return;
    [_channels addObject:channel];
    NSLog(@"%@", _channels);
}

- (void)removeChannel:(ICChannel *)channel
{
    [_channels removeObject:channel];
}


@end

