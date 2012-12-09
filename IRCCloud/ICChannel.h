//
//  ICChannel.h
//  IRCCloud
//
//  Created by Aditya KD on 21/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICBuffer.h"

@interface ICChannel : ICBuffer

@property (nonatomic, copy) NSDictionary *topic;
@property (nonatomic, strong) NSDictionary *members;
@property (nonatomic, strong) NSArray *ops;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *mode;

- (id)initWithName:(NSString *)name andBufferID:(NSNumber *)bid;
@end
