#import "SocketRocket/SRWebSocket.h"

@interface ICChatRequest:NSObject<SRWebSocketDelegate>{
	id delegate;
	SEL messageSelector;
	SEL errorSelector;
	BOOL connected;
	SRWebSocket *webSocket;
}
-(ICChatRequest *)initWithDelegate:(id)delegate selector:(SEL)selector errorSelector:(SEL)errorSelector;
@property(assign) BOOL connected;
@property(nonatomic,retain) SRWebSocket *webSocket;
@end
