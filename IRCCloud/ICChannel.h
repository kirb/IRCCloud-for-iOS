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
@property (nonatomic, copy) NSDate *creationDate;
@property (nonatomic, assign) int bid;

- (id)initWithName:(NSString *)name andBufferID:(int)bid;

@end
