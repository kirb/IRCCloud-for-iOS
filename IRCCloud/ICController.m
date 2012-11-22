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
        _connections = [[[NSMutableDictionary alloc] init] retain];
    }
    return self;
}

- (void)addNetwork:(ICNetwork *)connection
{
    [_connections setObject:connection forKey:[NSNumber numberWithInt:connection.cid]];
    NSLog(@"connections: %@", _connections);
}

- (void)removeNetwork:(ICNetwork *)connection
{
    [_connections removeObjectForKey:[NSNumber numberWithInt:connection.cid]];
    // here, a delegate should be notified.
}

- (ICNetwork *)networkForConnection:(NSNumber *)connectionID
{
    return [_connections objectForKey:connectionID];
}

- (void)dealloc
{
    [_connections release];
    [super dealloc];
}

@end
