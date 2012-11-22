//
//  ICChannel.m
//  IRCCloud
//
//  Created by Aditya KD on 21/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICChannel.h"

@implementation ICChannel

- (id)initWithName:(NSString *)name andBufferID:(NSNumber *)bid
{
    self = [super init];
    if (self) {
        _name = name;
        _bid = bid;
    }
    return self;
}

- (id)init
{
    NSAssert((_name == nil), @"Do not call init directly! Use -[ICChannel initWithName:andBufferID:] instead");
    return [self init];
}

- (id)description
{
    return [NSString stringWithFormat:@"Channel: %@, Topic: %@ Mode: %@ Type: %@", self.name, [self.topic objectForKey:@"text"], self.mode, self.type];
}

- (void)dealloc
{
    [_name release];
    [_creationDate release];
    [super dealloc];
}

@end
