//
//  ICChannel.h
//  IRCCloud
//
//  Created by Aditya KD on 21/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICChannel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSNumber *bid;
@property (nonatomic, copy) NSDictionary *topic;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSDate *creationDate;
@property (nonatomic, strong) NSDictionary *members;
@property (nonatomic, strong) NSString *mode;
@property (nonatomic, strong) NSArray *ops;

- (id)initWithName:(NSString *)name andBufferID:(NSNumber *)bid;

@end
