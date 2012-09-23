@interface ICServer:NSObject
@property(assign) int connectionID;
@property(nonatomic,retain) NSString *hostName;
@property(assign) int port;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *nick;
@property(nonatomic,retain) NSString *realName;
@property(nonatomic,retain) NSString *password;
@property(nonatomic,retain) NSString *nickServPass;
@property(nonatomic,retain) NSString *joinCommands;
@property(nonatomic,retain) NSMutableArray *ignores;
@property(assign) BOOL isAway;
@property(nonatomic,retain) NSString *awayMessage;
@property(assign) ICServerStatus status;
@property(nonatomic,retain) NSString *error;
@property(assign) int lag;
@property(nonatomic,retain) NSString *server;
@property(assign) BOOL hasIdent;
@property(nonatomic,retain) NSString *username;
@property(nonatomic,retain) NSString *userHost;
@property(nonatomic,retain) NSString *userMask;
@property(nonatomic,retain) NSMutableDictionary *buffers;
@property(assign) int bufferCount;
@end
