#import "ICGlobal.h"
#import "ICLogInViewController.h"
#import "ADTableViewInputCell.h"

@implementation ICLogInViewController
-(void)loadView{
	[super loadView];
	self.title=__(@"LOG_IN");
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
	return YES;
}
-(void)logIn{
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)table{
	return 1;
}
-(NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section{
	return 3;
}
-(NSString *)tableView:(UITableView *)table titleForFooterInSection:(NSInteger)section{
	return __(@"LOG_IN_DESCRIPTION");
}
-(UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)index{
	if(index.row==2){
		UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:@"logInButtonCell"]?:[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"logInButtonCell"];
		cell.textLabel.text=__(@"LOG_IN");
		cell.textLabel.textAlignment=UITextAlignmentCenter;
		return cell;
	}else{
		ADTableViewInputCell *cell=[table dequeueReusableCellWithIdentifier:@"logInTextCell"]?:[[ADTableViewInputCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"logInTextCell"];
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
	if(index.row==2)[self logIn];
	else [((ADTableViewInputCell *)[table cellForRowAtIndexPath:index]).accessoryView becomeFirstResponder];
}
-(void)viewDidLoad{
	[super viewDidLoad];
	[((ADTableViewInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]).textField becomeFirstResponder];
}
-(BOOL)textFieldShouldReturn:(UITextField *)field{
	if(field.tag==5100)[((ADTableViewInputCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]).textField becomeFirstResponder];
	else if(field.tag==5101)[self logIn];
	return YES;
}
@end
