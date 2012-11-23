//
//  ICBuffer.h
//  IRCCloud
//
//  Created by Aditya KD on 24/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICBuffer : NSObject
{
    NSNumber *_cid;
    NSNumber *_bid;
    NSNumber *_creationDate;
    NSNumber *_lastSeenEid;
    BOOL      _archived;
    NSString *_name;
}
@property (nonatomic, copy) NSNumber *cid;
@property (nonatomic, copy) NSNumber *bid;
@property (nonatomic, assign) BOOL archived;
@property (nonatomic, copy) NSNumber *creationDate;
@property (nonatomic, copy) NSNumber *lastSeenEid;
@property (nonatomic, copy) NSString *name;
@end
