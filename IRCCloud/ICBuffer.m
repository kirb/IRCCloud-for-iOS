//
//  ICBuffer.m
//  IRCCloud
//
//  Created by Aditya KD on 24/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import "ICBuffer.h"
#import "ICAppDelegate.h"

@implementation ICBuffer
@synthesize buffer = _buffer; // Xcode was throwing errors without that synthesize. STOOPID!

- (NSMutableArray *)buffer
{
    if (!_buffer)
        _buffer = [[NSMutableArray alloc] init];
    return _buffer;
}


/*
 For reference
 -> {"_reqid":1, "_method":"say", "cid":2, "to":"#channel", "msg":"hello world"}
 <- {"_reqid":1, "success":true, "type":"open_buffer", "cid":2, "name":"#channel"}
*/
- (void)sendMessage:(NSString *)message
{
    NSDictionary *messageDict = @{@"_reqid"  : [NSNumber numberWithInt:rand()],
                                  @"_method" : @"say",
                                  @"cid"     : self.cid,
                                  @"to"      : self.name,
                                  @"msg"     : message};
    [[(ICAppDelegate *)[UIApplication sharedApplication].delegate webSocket] sendJSONFromDictionary:messageDict];
}
@end
