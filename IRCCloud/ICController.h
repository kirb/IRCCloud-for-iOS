//
//  ICController.h
//  IRCCloud
//
//  Created by Aditya KD on 21/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ICNetwork;

@protocol IControllerDelegate <NSObject>
@required
- (void)controllerDidAddNetwork:(ICNetwork *)network;
- (void)controllerDidRemoveNetwork:(ICNetwork *)network;
@end

@interface ICController : NSObject
{
    __weak id<IControllerDelegate> _delegate;
}

@property (nonatomic, weak) id delegate;

+ (ICController *)sharedController;
- (void)addNetworkFromDictionary:(NSDictionary *)dict;
- (void)addNetwork:(ICNetwork *)connection;
- (void)removeNetworkWithCID:(NSNumber *)cid;
- (ICNetwork *)networkForConnection:(NSNumber *)connectionID;
- (NSArray *)networks;

@end
