#import "ICGlobal.h"
#import "ICRequest.h"
#import "ICChatRequestParser.h"
#import "ICApplication.h"

@implementation ICChatRequestParser
-(void)parseResponse:(NSDictionary *)json{
	if(![json objectForKey:@"type"])return;
	#define is(str) [[json objectForKey:@"type"]isEqualToString:str]
	if(is(@"header"))						{}//todo: use this to work out time offsets
	else if(is(@"idle"))					{}//ignored
	else if(is(@"stat_user"))				[ICApp receivedUserInfo:json];
	else if(is(@"num_invites")) 			{}//no point in doing this yet as alpha doesnt support invites
	else if(is(@"backlog_complete"))		[ICApp backlogLoaded];
	else if(is(@"makeserver"))				[ICApp addServer:json];
	else if(is(@"end_of_backlog"))			{}//???
	else if(is(@"makebuffer"))				[ICApp addBuffer:json];
	else if(is(@"channel_init"))			[ICApp initializeChannel:json];
	else if(is(@"status_changed"))			{}//todo: this
	else if(is(@"connection_lag"))			{}//todo: this too
	else if(is(@"heartbeat_echo"))			{}//and this
	else if(is(@"buffer_msg"))				[ICApp addMessage:json type:ICMessageTypeMessage];
	else if(is(@"buffer_me_msg"))			[ICApp addMessage:json type:ICMessageTypeMe];
	/*so, uh, gotta do all these...
	else if(is(@"notice"))					[ICApp addMessage:json type:ICMessageTypeNotice];
	else if(is(@"channel_timestamp"))		{}//meh
	else if(is(@"channel_url")) 			{}//why am i so lazy
	else if(is(@"channel_topic"))			[ICApp addMessage:json type:ICMessageTypeMOTD];
	else if(is(@"channel_topic_is"))		[ICApp addMessage:json type:ICMessageTypeMOTDIs];
	else if(is(@"channel_mode"))			[ICApp addMessage:json type:ICMessageTypeMode];
	else if(is(@"channel_mode_is")) 		[ICApp addMessage:json type:ICMessageTypeModeIs];
	else if(is(@"user_channel_mode"))		[ICApp addMessage:json type:ICMessageTypeUserMode];
	else if(is(@"member_updates"))			[ICApp updateMembers:json];
	else if(is(@"self_details"))			[ICApp updateOwnDetails:json];
	else if(is(@"user_away")||is(@"user_back")||is(@"self_away")
		||is(@"self_back")) 				[ICApp updateAwayStatus:json];
	else if(is(@"joined_channel"))			[ICApp addMessage:json type:ICMessageTypeJoin];
	else if(is(@"parted_channel")||is(@"you_parted_channel"))
											[ICApp addMessage:json type:ICMessageTypePart];
	else if(is(@"kicked_channel")||is(@"you_kicked_channel"))
											[ICApp addMessage:json type:ICMessageTypeKick];
	else if(is(@"quit")||is(@"quit_server"))[ICApp addMessage:json type:ICMessageTypeQuit];
	else if(is(@"nickchange")||is(@"you_nickchange")||is(@"rename_conversation"))
											[ICApp addMessage:json type:ICMessageTypeNick]; //attack of the 4 letter events.
	else if(is(@"delete_buffer"))			[ICApp updateBuffer:json type:ICBufferTypeDelete];
	else if(is(@"buffer_archived")) 		[ICApp updateBuffer:json type:ICBufferTypeArchive];
	else if(is(@"buffer_unarchived"))		[ICApp updateBuffer:json type:ICBufferTypeUnarchive];
	else if(is(@"server_details_changed"))	[ICApp updateServer:json];
	else if(is(@"whois_response"))			[ICApp addMessage:json type:ICMessageTypeWhois];
	else if(is(@"set_ignores")) 			[ICApp updateIgnores:json];
	else if(is(@"link_channel"))			[ICApp updateBuffer:json type:ICBufferTypeRename];
	else if(is(@"isupport_params")) 		[ICApp addISupportInfo:json];
	else if(is(@"myinfo"))					[ICApp updateServerInfo:json];
	*/
	else if(is(@"irccloud_auth_error")) 	[[[UIAlertView alloc]initWithTitle:__(@"AUTHENITCATION_ERROR") message:__(@"AUTHENITCATION_ERROR_MESSAGE") delegate:nil cancelButtonTitle:__(@"OK") otherButtonTitles:nil]show];
	else									NSLog(@"Warning: Unhandled response: %@",[json objectForKey:@"type"]);
}
-(void)receivedResponse:(NSDictionary *)json{
	NSLog(@"got data = %@",json);
	if(![json objectForKey:@"type"])return;
	else if([[json objectForKey:@"type"]isEqualToString:@"oob_include"])[ICRequest requestWithPage:[[json objectForKey:@"url"]stringByReplacingOccurrencesOfString:@"/chat/" withString:@""] parameters:nil delegate:self selector:@selector(receivedResponse:)];
	else [self parseResponse:json];
}
-(void)receivedError:(NSError *)err{
	NSLog(@"boom. user info = %@",err.userInfo);
	[[[UIAlertView alloc]initWithTitle:__(@"ERROR_OCCURRED") message:[NSString stringWithFormat:__(@"ERROR_OCCURRED_MESSAGE"),[err localizedDescription]] delegate:nil cancelButtonTitle:__(@"OK") otherButtonTitles:nil]show];
}
@end
