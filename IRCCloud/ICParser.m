//
//  ICParser.m
//  IRCCloud
//
//  Created by Aditya KD on 22/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICParser.h"
#import "ICController.h"
#import "ICNetwork.h"
#import "ICChannel.h"

@implementation ICParser
+ (ICParser *)sharedParser
{
    // a sharedInstance is better than continually creating a new instance of the parser
    static ICParser *parser;
    if (!parser)
        parser = [[self alloc] init];
    return parser;
}

- (void)parse:(NSDictionary *)json
{
    if ([json[@"type"] isEqualToString:@"header"]) {
        NSLog(@"Header received, stream has begun");
    }
    if ([json[@"type"] isEqualToString:@"makeserver"]) {
        [kSharedController addNetworkFromDictionary:[json copy]];
    }
    if ([json[@"type"] isEqualToString:@"channel_init"])
        [self parseChannel:json];
}

- (void)parseChannel:(NSDictionary *)json
{
    ICNetwork *channelNetwork = [[ICController sharedController] networkForConnection:json[@"cid"]];
    [channelNetwork addChannelFromDictionary:json];
}

@end
