//
//  ICBuffer.h
//  IRCCloud
//
//  Created by Aditya KD on 24/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ICBuffer;
@protocol ICBufferDelegate <NSObject>
@optional
- (void)addedMessageToBuffer:(ICBuffer *)buffer; //ICParser sends the delegate this message. (L79, ICParser.m)
@end

@interface ICBuffer : NSObject
{
    NSNumber *_cid;
    NSNumber *_bid;
    NSNumber *_creationDate;
    NSNumber *_lastSeenEid;
    NSString *_name;
    __weak id<ICBufferDelegate> _delegate;
}
@property (nonatomic, copy) NSNumber *cid;
@property (nonatomic, copy) NSNumber *bid;
@property (nonatomic, copy) NSNumber *creationDate;
@property (nonatomic, copy) NSNumber *lastSeenEid;
@property (nonatomic, copy) NSString *name;
@property (strong, nonatomic, readonly) NSMutableArray *buffer; // an array of NSDictionaries, sent along by ICParser.

@property (nonatomic, weak) id delegate;

- (void)sendMessage:(NSString *)message;

@end
