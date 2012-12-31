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
    BOOL            _waitingForCompletion;
    NSMutableArray *_backLog; // backLog, as in the backlog from not parsing while waitingForCompletion is true.
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
        else if (([json[@"type"] isEqualToString:@"buffer_msg"]) || ([json[@"type"] isEqualToString:@"buffer_me_msg"])) {
            if (![json[@"chan"] hasPrefix:@"#"]) {
                // it is a PM
                ; // for now.
            }
            else {
                ICNetwork *channelNetwork = [kSharedController networkForConnection:json[@"cid"]];
                ICChannel *channel = [channelNetwork channelWithBID:json[@"bid"]];
                if (!channel)
                    [NSException raise:@"WTF" format:@"Channel doesn't exist"];
                [[channel buffer] addObject:json];
            }
        }
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.loadingOOB = NO;
}

#define kTypeEqual(string) [json[@"type"] isEqualToString:string]

- (void)parse:(NSDictionary *)json // be sure to rename the "json" in the define if this is renamed.
{
    if (!self.loadingOOB) {
        if (_waitingForCompletion) {
            if (!_backLog)
                _backLog = [[NSMutableArray alloc] init];
            [_backLog addObject:json];
            return;
        }
#pragma mark Network Messages
        if (kTypeEqual(@"makeserver")) {
            [kSharedController addNetworkFromDictionary:[json copy]];
        }
        else if (kTypeEqual(@"status_changed")) {
            [[kSharedController networkForConnection:json[@"cid"]] setStatus:json[@"newStatus"]];
        }
        else if (kTypeEqual(@"connection_lag")) {
            [[kSharedController networkForConnection:json[@"cid"]] setConnectionLag:json[@"lag"]];
        }
        
#pragma mark Channel Messages
        else if (kTypeEqual(@"channel_url")) {
            ICChannel *channel = [[kSharedController networkForConnection:json[@"cid"]] channelWithBID:json[@"bid"]];
            channel.channelURL = json[@"url"];
        }
        else if (kTypeEqual(@"channel_init")) {
            ICNetwork *channelNetwork = [[ICController sharedController] networkForConnection:json[@"cid"]];
            [channelNetwork addChannelFromDictionary:[json copy]];
        }
        else if (kTypeEqual(@"you_parted_channel")) {
            ICNetwork *channelNetwork = [[ICController sharedController] networkForConnection:json[@"cid"]];
            [channelNetwork removeChannelWithBID:json[@"bid"]];
        }

#pragma mark Buffer Messages
        else if (kTypeEqual(@"buffer_msg") || kTypeEqual(@"buffer_me_msg")) {
            
            ICChannel *channel = [[kSharedController networkForConnection:json[@"cid"]] channelWithBID:json[@"bid"]];
            [[channel buffer] addObject:[json copy]];
            
            if ([channel.delegate respondsToSelector:@selector(addedMessageToBuffer:)]) {
                _waitingForCompletion = YES;
                [self.messageQueue addOperationWithBlock:^{
                    [channel.delegate performSelectorOnMainThread:@selector(addedMessageToBuffer:) withObject:channel waitUntilDone:YES];
                    _waitingForCompletion = NO;
                    if (_backLog.count > 0) {
                        for (NSDictionary *dict in [_backLog copy]) {
                            [_backLog removeObject:dict];
                            [self parse:dict];
                        }
                    }
                }];
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
