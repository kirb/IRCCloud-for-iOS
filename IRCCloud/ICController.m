//
//  ICController.m
//  IRCCloud
//
//  Created by Aditya KD on 21/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICController.h"
#import "ICNetwork.h"

@implementation ICController
{
    __strong NSMutableDictionary *_connections;
}

static ICController *controller;

+ (ICController *)sharedController
{
    if (!controller)
        controller = [[self alloc] init];
    return controller;
}

- (id)init
{
    self = [super init];
    if (self) {
        _connections = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addNetworkFromDictionary:(NSDictionary *)dict
{
    ICNetwork *network = [[ICNetwork alloc] initWithNetworkNamed:dict[@"name"]
                                                       hostName:dict[@"hostname"]
                                                            SSL:[(NSNumber *)dict[@"ssl"] boolValue]
                                                           port:(NSNumber *)dict[@"port"]
                                                   connectionID:(NSNumber *)dict[@"cid"]];
    network.status = dict[@"status"];
    [[ICController sharedController] addNetwork:network];
}

- (void)addNetwork:(ICNetwork *)connection
{
    [_connections setObject:connection forKey:connection.cid];
    if (_delegate) {
        [_delegate controllerDidAddNetwork:connection];
    }
        
    NSLog(@"connections: %@", _connections);
}

- (void)removeNetworkWithCID:(NSNumber *)cid
{
    if (_delegate) {
        [_delegate controllerDidRemoveNetwork:[_connections objectForKey:cid]];
    }
    [_connections removeObjectForKey:cid];
}

- (ICNetwork *)networkForConnection:(NSNumber *)connectionID
{
    return [_connections objectForKey:connectionID];
}

- (NSArray *)networks
{
    return [_connections allKeys];
}

@end
