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
{
    NSMutableArray *_toBeParsed;
}

+ (ICParser *)sharedParser
{
    // a sharedInstance is better than continually creating a new instance of the parser
    static ICParser *parser;
    if (!parser)
        parser = [[self alloc] init];
    return parser;
}

- (void)parseOOBArray:(NSArray *)oobArray
{
    self.loadingOOB = YES;
    for (NSDictionary *json in oobArray)
    {
        if ([json[@"type"] isEqualToString:@"makeserver"]) {
            NSLog(@"%@", json[@"name"]);
            [kSharedController addNetworkFromDictionary:[json copy]];
        }   
        else if ([json[@"type"] isEqualToString:@"makebuffer"]) {
            if ([json[@"buffer_type"] isEqualToString:@"channel"]) {
                if (json[@"archived"])
                    ;
                else
                    [[kSharedController networkForConnection:json[@"cid"]] addOOBChannelFromDictionary:json];
            }
        }
        else if ([json[@"type"] isEqualToString:@"channel_init"]) {
            ICNetwork *channelNetwork = [[ICController sharedController] networkForConnection:json[@"cid"]];
            [channelNetwork addChannelFromDictionary:json];
        }
        else if ([json[@"type"] isEqualToString:@"buffer_msg"]) {
            ICNetwork *channelNetwork = [kSharedController networkForConnection:json[@"cid"]];
            for (ICChannel *channel in [channelNetwork channels]){
                if ([channel.bid intValue] == [json[@"bid"] intValue]) {
                    [[channel buffer] addObject:json];
                    break;
                }
            }
        }
    }
    self.loadingOOB = NO;
}

- (void)parse:(NSDictionary *)json
{
    if (!self.loadingOOB) {
        if ([json[@"type"] isEqualToString:@"makeserver"]) {
            [kSharedController addNetworkFromDictionary:[json copy]];
        }
        else if ([json[@"type"] isEqualToString:@"channel_init"]) {
            ICNetwork *channelNetwork = [[ICController sharedController] networkForConnection:json[@"cid"]];
            [channelNetwork addChannelFromDictionary:[json copy]];
        }
        else if ([json[@"type"] isEqualToString:@"buffer_msg"]) {
            ICNetwork *channelNetwork = [kSharedController networkForConnection:json[@"cid"]];
            for (ICChannel *channel in [channelNetwork channels]){
                if ([channel.bid intValue] == [json[@"bid"] intValue]) {
                    [[channel buffer] addObject:[json copy]];
                    if ([channel.delegate respondsToSelector:@selector(addedMessageToBuffer:)]) {
                        [channel.delegate performSelectorOnMainThread:@selector(addedMessageToBuffer:) withObject:channel waitUntilDone:YES];
                    }
                    break;
                }
            }
        }
    }
    else {
        [_toBeParsed addObject:json];
    }
}

- (void)setLoadingOOB:(BOOL)loadingOOB
{
    if (loadingOOB == NO) {
        _loadingOOB = loadingOOB; // set the ivar
        for (NSDictionary *meh in _toBeParsed) {
            // parse all the things!
            [self parse:meh];
        }
    }
    _loadingOOB = loadingOOB;
}

@end
