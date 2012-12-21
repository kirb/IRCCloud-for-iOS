//
//  ICParser.m
//  IRCCloud
//
//  Created by Aditya KD on 22/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
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
    if (!parser) {
        parser = [[self alloc] init];
    }
    return parser;
}

- (ICParser *)init
{
    if (self = [super init]) {
        _messageQueue = [NSOperationQueue new];
        _messageQueue.name = @"ICParserQueue";
        _messageQueue.maxConcurrentOperationCount = 1;
    }
    return self;
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.loadingOOB = NO;
}

static BOOL waitingForCompletion = NO;
static NSMutableArray *backLog; // backLog, as in the backlog from not parsing while waitingForCompletion is true.
- (void)parse:(NSDictionary *)json
{
    if (!self.loadingOOB) {
        if (waitingForCompletion) {
            if (!backLog)
                backLog = [[NSMutableArray alloc] init];
            [backLog addObject:json];
            return;
        }
        
        if ([json[@"type"] isEqualToString:@"makeserver"]) {
            [kSharedController addNetworkFromDictionary:[json copy]];
        }
        else if ([json[@"type"] isEqualToString:@"channel_init"]) {
            ICNetwork *channelNetwork = [[ICController sharedController] networkForConnection:json[@"cid"]];
            [channelNetwork addChannelFromDictionary:[json copy]];
        }
        else if ([json[@"type"] isEqualToString:@"you_parted_channel"]) {
            ICNetwork *channelNetwork = [[ICController sharedController] networkForConnection:json[@"cid"]];
            [channelNetwork removeChannelWithBID:json[@"bid"]];
        }
        else if ([json[@"type"] isEqualToString:@"buffer_msg"])
        {
            ICNetwork *channelNetwork = [kSharedController networkForConnection:json[@"cid"]];
            for (__strong ICChannel *channel in [channelNetwork channels])
            {
                if ([channel.bid intValue] == [json[@"bid"] intValue])
                {
                    [[channel buffer] addObject:[json copy]];
                    if ([channel.delegate respondsToSelector:@selector(addedMessageToBuffer:)])
                    {
                        waitingForCompletion = YES;
                        [self.messageQueue addOperationWithBlock:^{
                            [channel.delegate performSelectorOnMainThread:@selector(addedMessageToBuffer:) withObject:channel waitUntilDone:YES];
                            waitingForCompletion = NO;
                            if (backLog.count > 0) {
                                for (NSDictionary *dict in [backLog copy]) {
                                    [backLog removeObject:dict];
                                    [self parse:dict];
                                }
                            }
                        }];
                    }
                    break;
                }
            }
        }
    }
    else {
        [_toBeParsed addObject:json]; // _toBeParsed will only be used when the OOB is being fetched.
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
