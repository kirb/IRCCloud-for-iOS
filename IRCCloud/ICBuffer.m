//
//  ICBuffer.m
//  IRCCloud
//
//  Created by Aditya KD on 24/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import "ICBuffer.h"

@implementation ICBuffer
@synthesize buffer = _buffer; // Xcode was throwing errors without that synthesize. STOOPID!

- (NSMutableArray *)buffer
{
    if (!_buffer)
        _buffer = [[NSMutableArray alloc] init];
    return _buffer;
}
@end
