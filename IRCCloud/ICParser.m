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
    @autoreleasepool {
        if ([json[@"type"] isEqualToString:@"header"]) {
            NSLog(@"Header received, stream has begun");
        }

        if ([json[@"type"] isEqualToString:@"makeserver"]) {
            [self parseNetwork:json];
        }
        if ([json[@"type"] isEqualToString:@"channel_init"])
            [self parseChannel:json];
    
    
    }
}

- (void)parseNetwork:(NSDictionary *)json
{
    ICNetwork *network = [[ICNetwork alloc] initWithNetworkNamed:json[@"name"]
                                                         hostName:json[@"hostname"]
                                                              SSL:[(NSNumber *)json[@"ssl"] boolValue]
                                                             port:[(NSNumber *)json[@"port"] intValue]
                                                     connectionID:[(NSNumber *)json[@"cid"] intValue]];
    network.status = json[@"status"];
    [[ICController sharedController] addNetwork:network];
}

- (void)parseChannel:(NSDictionary *)json
{
    if (![[ICController sharedController] networkForConnection:json[@"cid"]])
        return;
    ICChannel *channel = [[ICChannel alloc] initWithName:json[@"chan"] andBufferID:json[@"bid"]];
    channel.members = json[@"members"];
    channel.creationDate = json[@"created"];
    channel.topic = json[@"topic"];
    channel.type = json[@"channel_type"];
    channel.mode = json[@"mode"];
    channel.ops = json[@"ops"];
    
    ICNetwork *channelNetwork = [[ICController sharedController] networkForConnection:json[@"cid"]];
    [channelNetwork addChannel:channel];
}

@end
