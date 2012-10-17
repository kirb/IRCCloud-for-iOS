//
//  ICWebSocketDelegate.h
//  IRCCloud
//
//  Created by Adam D on 2/10/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebSocket.h"

@interface ICWebSocketDelegate : NSObject <WebSocketDelegate> {
	WebSocket *webSocket;
}

-(void)open;
-(void)close;

@end
