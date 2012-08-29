#import <objc/runtime.h>
#import "ICGlobal.h"
#import "ICApplication.h"
#import "ICNetworksViewController.h"
#import "ICChatViewController.h"
#import "ICLogInViewController.h"
#import "ICChatRequest.h"
#import "ICChatRequestParser.h"
#import "ICServer.h"
#import "ICBuffer.h"
//#import "NSString+Base64.h"

@implementation ICApplication
@synthesize window,cookie,userIsOnAlpha,connection,servers;
-(ICApplication *)init{
	if((self=[super init])){
		self.userIsOnAlpha=NO;
		self.servers=[NSMutableDictionary dictionary];
	}
	return self;
}
-(void)applicationDidFinishLaunching:(UIApplication *)application{
	window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
	NSDictionary *prefs=[NSDictionary dictionaryWithContentsOfFile:prefpath];
	//self.cookie=[prefs objectForKey:@"Cookie"]?[[prefs objectForKey:@"Cookie"]base64DecodedString]:nil;
	self.cookie=[prefs objectForKey:@"Cookie"];
	self.userIsOnAlpha=[prefs objectForKey:@"Alpha"]?[[prefs objectForKey:@"Alpha"]boolValue]:NO;
	NSLog(@"mah cookie = %@",self.cookie);
	sidebar=[[ICNetworksViewController alloc]init];
	sidebarNavController=[[[UINavigationController alloc]initWithRootViewController:sidebar]autorelease];
	if(isPad){
		viewController=[[objc_getClass("UISplitViewController") alloc]init];
		viewController.delegate=self;
		main=[[ICChatViewController alloc]init];
		mainNavController=[[[UINavigationController alloc]initWithRootViewController:main]autorelease];
		viewController.viewControllers=[NSArray arrayWithObjects:sidebarNavController,mainNavController,nil];
		[window addSubview:viewController.view];
	}else [window addSubview:sidebarNavController.view];
	if(self.cookie==nil&&!isPad)[sidebar showLogIn];
	[window makeKeyAndVisible];
	if(self.cookie!=nil)[self connect];
}
-(void)dealloc{
	[window release];
	[sidebar release];
	[main release];
	[sidebarNavController release];
	[mainNavController release];
	[super dealloc];
}
-(void)splitViewController:(UISplitViewController *)split willHideViewController:(UIViewController *)ctrl withBarButtonItem:(UIBarButtonItem *)item forPopoverController:(UIPopoverController *)popover{
	sidebar.title=item.title=__(@"CONNECTIONS");
	main.navigationItem.leftBarButtonItem=item;
}
-(void)splitViewController:(UISplitViewController *)split willShowViewController:(UIViewController *)ctrl invalidatingBarButtonItem:(UIBarButtonItem *)item{
	sidebar.title=__(@"IRCCLOUD");
	main.navigationItem.leftBarButtonItem=nil;
}
-(void)connect{
	ICChatRequestParser *parser=[[ICChatRequestParser alloc]init];
	self.connection=[[ICChatRequest alloc]initWithDelegate:parser selector:@selector(receivedResponse:) errorSelector:@selector(receivedError:)];
}
-(void)receivedUserInfo:(NSDictionary *)json{}//todo
-(void)backlogLoaded{//threedo
	NSLog(@"yay, backlog loaded! %@",self.servers);
}
-(void)addServer:(NSDictionary *)json{
	ICServer *server=[[ICServer alloc]init];
	server.connectionID=[[json objectForKey:@"cid"]intValue];
	server.hostName=[json objectForKey:@"hostname"];
	server.port=[[json objectForKey:@"port"]intValue];
	server.name=[json objectForKey:@"name"];
	server.nick=[json objectForKey:@"nick"];
	server.realName=[json objectForKey:@"realname"];
	server.password=[json objectForKey:@"password"];
	server.nickServPass=[json objectForKey:@"nickserv_pass"];
	server.joinCommands=[json objectForKey:@"join_commands"]?:@"";
	server.ignores=[json objectForKey:@"ignores"];
	server.isAway=[[json objectForKey:@"away"]boolValue];
	server.awayMessage=[[json objectForKey:@"away"]boolValue]?[json objectForKey:@"away"]:nil;
	server.status=ICServerStatusUnknown;
	#define iss(str) [[json objectForKey:@"status"]isEqualToString:str]
	if(iss(@"queued"))server.status=ICServerStatusQueued;
	else if(iss(@"connecting"))server.status=ICServerStatusConnecting;
	else if(iss(@"connected"))server.status=ICServerStatusConnected;
	else if(iss(@"connected_joining"))server.status=ICServerStatusJoining;
	else if(iss(@"connected_ready"))server.status=ICServerStatusReady;
	else if(iss(@"quitting"))server.status=ICServerStatusQuitting;
	else if(iss(@"disconnected"))server.status=ICServerStatusDisconnected;
	else if(iss(@"pool_unavailable"))server.status=ICServerStatusPoolUnavailable;
	else if(iss(@"waiting_to_retry"))server.status=ICServerStatusWaiting;
	else if(iss(@"ip_retry"))server.status=ICServerStatusRetrying;
	server.error=nil; //meh, for now
	server.lag=[[json objectForKey:@"lag"]intValue];
	server.server=[json objectForKey:@"ircserver"];
	server.hasIdent=[[json objectForKey:@"ident_prefix"]boolValue];
	server.username=[json objectForKey:@"user"];
	server.userHost=[json objectForKey:@"userhost"];
	server.userMask=[json objectForKey:@"usermask"];
	server.buffers=[NSMutableDictionary dictionary];
	server.bufferCount=[[json objectForKey:@"num_buffers"]intValue];
	[self.servers setObject:server forKey:[NSString stringWithFormat:@"%i",server.connectionID]]; //whew!
}
-(void)addBuffer:(NSDictionary *)json{
	ICBuffer *buffer=[[ICBuffer alloc]init];
	buffer.connectionID=[[json objectForKey:@"cid"]intValue];
	buffer.bufferID=[[json objectForKey:@"bid"]intValue];
	buffer.type=ICBufferTypeUnknown;
	#define ist(str) [[json objectForKey:@"buffer_type"]isEqualToString:str]
	if(ist(@"console"))buffer.type=ICBufferTypeConsole;
	else if(ist(@"channel"))buffer.type=ICBufferTypeChannel;
	else if(ist(@"conversation"))buffer.type=ICBufferTypeConversation;
	buffer.name=[json objectForKey:@"name"];
	buffer.deferredLoad=[[json objectForKey:@"deferred"]boolValue];
	buffer.archived=[[json objectForKey:@"archived"]boolValue];
	buffer.earliestEventID=[[json objectForKey:@"min_eid"]intValue];
	buffer.created=[NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"created"]doubleValue]];
	buffer.lastSeenEventID=[[json objectForKey:@"last_seen_eid"]intValue];
	[[[self.servers objectForKey:[NSString stringWithFormat:@"%i",buffer.connectionID]]buffers]
		setObject:buffer forKey:[NSString stringWithFormat:@"%i",buffer.bufferID]];
}
-(void)initializeChannel:(NSDictionary *)json{
	ICBuffer *buffer=[[[self.servers objectForKey:[NSString stringWithFormat:@"%i",[[json objectForKey:@"cid"]intValue]]]buffers]objectForKey:
		[NSString stringWithFormat:@"%i",[[json objectForKey:@"bid"]intValue]]];
	buffer.members=[[json objectForKey:@"members"]mutableCopy];
	buffer.mode=[json objectForKey:@"mode"];
	buffer.ops=[json objectForKey:@"ops"]; //for now
	buffer.topic=[[json objectForKey:@"topic"]objectForKey:@"text"];
	buffer.topicSetBy=[[json objectForKey:@"topic"]objectForKey:@"usermask"];
	buffer.topicSetAt=[NSDate dateWithTimeIntervalSince1970:[[[json objectForKey:@"topic"]objectForKey:@"time"]doubleValue]];
	buffer.created=[NSDate dateWithTimeIntervalSince1970:[[json objectForKey:@"timestamp"]doubleValue]];
	buffer.security=ICBufferSecurityUnknown;
	#define ise(str) [[json objectForKey:@"channel_type"]isEqualToString:str]
	if(ise(@"public"))buffer.security=ICBufferSecurityPublic;
	else if(ise(@"private"))buffer.security=ICBufferSecurityPrivate;
	else if(ise(@"secret"))buffer.security=ICBufferSecuritySecret;
}
-(void)addMessage:(NSDictionary *)json type:(ICMessageType)type{}//fourdo
@end
