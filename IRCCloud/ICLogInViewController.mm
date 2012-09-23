#import "ICGlobal.h"
#import "ICLogInViewController.h"
#import "ADTableViewInputCell.h"
#import "ICRequest.h"
#import "ICApplication.h"
//#import "NSString+Base64.h"

BOOL onAlpha=NO;

@implementation ICLogInViewController
-(ICLogInViewController *)init{
	if((self=[super init]))isLoggingIn=NO;
	return self;
}
-(void)loadView{
	[super loadView];
	self.title=__(@"LOG_IN");
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
	return YES;
}
-(void)logIn{
	logInError=nil;
	NSString *email=((ADTableViewInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).textField.text;
	NSString *pass=((ADTableViewInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]).textField.text;
	if([email isEqualToString:@""]||[pass isEqualToString:@""])return;
	[ICRequest requestWithPage:@"login" parameters:[NSString stringWithFormat:@"email=%@&password=%@",
		[email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
		[pass stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
		alpha:onAlpha=((UISwitch *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]].accessoryView).on
		delegate:self selector:@selector(_gotSessionCookie:)];
	[(ICApplication *)[UIApplication sharedApplication]setUserIsOnAlpha:onAlpha];
	if(!isLoggingIn){
		isLoggingIn=YES;
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:1],[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:2 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1],nil] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView reloadData];
		[ICApp sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
	}
}
-(void)_gotSessionCookie:(NSDictionary *)json{
	NSLog(@"json = %@",json);
	BOOL reshow=NO;
	isLoggingIn=NO;
	logInError=nil;
	if([json objectForKey:@"success"]&&[[json objectForKey:@"success"]boolValue]&&[json objectForKey:@"session"]){
		[self dismissModalViewControllerAnimated:YES];
		[ICApp setCookie:[json objectForKey:@"session"]];
		NSMutableDictionary *prefs=[NSMutableDictionary dictionaryWithContentsOfFile:prefpath];
		//[prefs setObject:[NSString stringWithBase64EncodedString:[json objectForKey:@"session"]] forKey:@"Cookie"];
		[prefs setObject:[json objectForKey:@"session"] forKey:@"Cookie"];
		[prefs setObject:[NSNumber numberWithBool:onAlpha] forKey:@"Alpha"];
		[prefs writeToFile:prefpath atomically:YES];
		[ICApp connect];
	}else if([json objectForKey:@"message"]){
		if([[json objectForKey:@"message"]isEqualToString:@"migrated"])logInError=__(@"ACCOUNT_MIGRATED");
		else if([[json objectForKey:@"message"]isEqualToString:@"already_signed_in"])logInError=__(@"INTERNAL_ERROR");
		else if([[json objectForKey:@"message"]isEqualToString:@"auth"])logInError=__(@"WRONG_EMAIL_OR_PASSWORD");
		else logInError=__(@"UNKNOWN_ERROR");
		reshow=YES;
	}else{
		logInError=__(@"LOG_IN_ERROR");
		reshow=YES;
	}
	if(reshow){
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:1],[NSIndexPath indexPathForRow:1 inSection:1],[NSIndexPath indexPathForRow:2 inSection:1],[NSIndexPath indexPathForRow:3 inSection:1],nil] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView reloadData];
	}
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)table{
	return 2;
}
-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
	if(isLoggingIn)return 0;
	return section==1?4:0;
}
-(NSString *)tableView:(UITableView *)table titleForFooterInSection:(NSInteger)section{
	switch(section){
		case 0:return isLoggingIn?__(@"PLEASE_WAIT"):(logInError?logInError:nil);break;
		case 1:return !isLoggingIn?__(@"LOG_IN_DESCRIPTION"):nil;break;
		default:return nil;break;
	}
}
-(UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)index{
	if(isLoggingIn||index.section==0)return nil;
	NSString *ident=@"";
	switch(index.row){
		case 0:ident=@"logInEmailCell";break;
		case 1:ident=@"logInPasswordCell";break;
		case 2:ident=@"logInAlphaCell";break;
		case 3:ident=@"logInButtonCell";break;
	}
	if(index.row==3){
		UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:ident]?:[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
		cell.textLabel.text=__(@"LOG_IN");
		cell.textLabel.textAlignment=UITextAlignmentCenter;
		return cell;
	}else if(index.row==2){
		UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:ident]?:[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
		cell.textLabel.text=__(@"ALPHA_USER");
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		UISwitch *switchy=[[UISwitch alloc]init];
		cell.accessoryView=switchy;
		return cell;
	}else{
		ADTableViewInputCell *cell=[table dequeueReusableCellWithIdentifier:ident]?:[[ADTableViewInputCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ident];
		cell.selectionStyle=UITableViewCellSelectionStyleNone;
		cell.textField.enablesReturnKeyAutomatically=YES;
		cell.textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
		cell.textField.autocorrectionType=UITextAutocorrectionTypeNo;
		cell.textField.delegate=self;
		if(index.row==0){
			cell.textLabel.text=__(@"EMAIL");
			cell.textField.keyboardType=UIKeyboardTypeEmailAddress;
			cell.textField.returnKeyType=UIReturnKeyNext;
			cell.textField.tag=5100;
		}else{
			cell.textLabel.text=__(@"PASSWORD");
			cell.textField.returnKeyType=UIReturnKeyGo;
			cell.textField.secureTextEntry=YES;
			cell.textField.tag=5101;
		}
		return cell;
	}
	return nil;
}
-(void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)index{
	[table deselectRowAtIndexPath:index animated:YES];
	if(index.row==3)[self logIn];
	else if(index.row!=2)[((ADTableViewInputCell *)[table cellForRowAtIndexPath:index]).accessoryView becomeFirstResponder];
}
-(void)viewDidLoad{
	[super viewDidLoad];
	[((ADTableViewInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).textField becomeFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)field{
	if(field.tag==5100)[((ADTableViewInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]).textField becomeFirstResponder];
	else if(field.tag==5101)[self logIn];
	return YES;
}
@end
