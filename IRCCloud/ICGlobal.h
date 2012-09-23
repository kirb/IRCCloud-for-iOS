typedef enum{
	ICMessageTypeMessage,
	ICMessageTypeMe
} ICMessageType;

typedef enum{
	ICServerStatusUnknown,
	ICServerStatusQueued,
	ICServerStatusConnecting,
	ICServerStatusConnected,
	ICServerStatusJoining,
	ICServerStatusReady,
	ICServerStatusQuitting,
	ICServerStatusDisconnected,
	ICServerStatusPoolUnavailable,
	ICServerStatusWaiting,
	ICServerStatusRetrying
} ICServerStatus;

typedef enum{
	ICBufferTypeUnknown,
	ICBufferTypeConsole,
	ICBufferTypeChannel,
	ICBufferTypeConversation
} ICBufferType;

typedef enum{
	ICBufferSecurityUnknown,
	ICBufferSecurityPublic,
	ICBufferSecurityPrivate,
	ICBufferSecuritySecret
} ICBufferSecurity;

#define ICGetServer(server) [[ICApp servers]objectForKey:[NSString stringWithFormat:@"%i",server]]
#define ICGetBuffer(server,buffer) [ICGetServer(server).buffers objectForKey:[NSString stringWithFormat:@"%i",buffer]]
#define __(key) [[NSBundle mainBundle]localizedStringForKey:key value:key table:@"IRCCloud"]
#define version @"0.0.1"
#define isPad ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
#define prefpath @"/var/mobile/Library/Preferences/ws.hbang.irccloud.plist"
#define ICApp (ICApplication *)[UIApplication sharedApplication]
#define betaURL @"irccloud.com"
#define alphaURL @"alpha.irccloud.com"
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:a]
