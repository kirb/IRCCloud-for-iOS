//
//  ICParser.h
//  IRCCloud
//
//  Created by Aditya KD on 22/11/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICParser : NSObject

@property (nonatomic, assign) BOOL loadingOOB;

+ (ICParser *)sharedParser;
- (void)parse:(NSDictionary *)json;
- (void)parseOOBArray:(NSArray *)oobArray;

@end
