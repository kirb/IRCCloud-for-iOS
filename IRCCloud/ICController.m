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
    __strong NSMutableArray *_connections;
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
        _connections = [[[NSMutableArray alloc] init] retain];
    }
    return self;
}

- (void)addNetwork:(ICNetwork *)connection
{
    [_connections addObject:connection];
}

- (void)removeNetwork:(ICNetwork *)connection
{
    [_connections removeObject:connection];
    // here, a delegate should be notified.
}

- (void)dealloc
{
    [_connections release];
    [super dealloc];
}

@end
