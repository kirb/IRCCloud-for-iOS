#import "ICGlobal.h"
#import "ICSettingsViewController.h"

@implementation ICSettingsViewController
-(void)loadView{
	[super loadView];
	self.tableView.delegate=self;
	self.tableView.dataSource=self;
	self.title=__(@"SETTINGS");
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
	return YES;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)table{
	return 3;
}
-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
	switch(section){
		case 0:return 1;break;
		case 1:return 0;break;
		case 2:return 2;break;
		default:return nil;break;
	}
}
-(NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section{
	switch(section){
		case 0:return __(@"ACCOUNT");break;
		case 1:return [NSString stringWithFormat:__(@"VERSION"),version];break;
		default:return nil;break;
	}
}
-(NSString *)tableView:(UITableView *)table titleForFooterInSection:(NSInteger)section{
	return section==1?__(@"AUTHOR"):nil;
}
-(UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)index{
	UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:index.section==0?@"settingsSwitchCell":@"settingsFollowCell"]?:[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:index.section==0?@"settingsSwitchCell":@"settingsFollowCell"];
	if(index.section==0){
		cell.textLabel.text=__(@"LOG_OUT");
		cell.textLabel.textAlignment=UITextAlignmentCenter;
	}else{
		cell.textLabel.text=__(index.row==0?@"FOLLOW_ME":@"FOLLOW_IRCCLOUD");
		cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
	}
	return cell;
}
-(void)viewWillDisappear{
	//TODO: make settings that need to be saved here
}
-(void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)index{
	[table deselectRowAtIndexPath:index animated:YES];
	if(index.section==2){
		NSString *account=index.row==0?@"thekirbylover":@"IRCCloud";
		if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"tweetbot:"]])[[UIApplication sharedApplication]openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:account]]];
		else if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"tweetings:"]])[[UIApplication sharedApplication]openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:account]]];
		else if([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"twitter:"]])[[UIApplication sharedApplication]openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:account]]];
		else [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[@"http://twitter.com/intent/follow?screen_name=" stringByAppendingString:account]]];
	}
}
@end
