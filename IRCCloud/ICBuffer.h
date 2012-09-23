#import "ICGlobal.h"

@interface ICBuffer:NSObject
@property(assign) int connectionID;
@property(assign) int bufferID;
@property(assign) ICBufferType type;
@property(nonatomic,retain) NSString *name;
@property(assign) BOOL deferredLoad;
@property(assign) BOOL archived;
@property(assign) int earliestEventID;
@property(nonatomic,retain) NSDate *created;
@property(assign) int lastSeenEventID;
@property(nonatomic,retain) NSMutableArray *members;
@property(nonatomic,retain) NSString *mode;
@property(nonatomic,retain) NSMutableArray *ops;
@property(nonatomic,retain) NSString *topic;
@property(nonatomic,retain) NSString *topicSetBy;
@property(nonatomic,retain) NSDate *topicSetAt;
@property(assign) ICBufferSecurity security;
@end
