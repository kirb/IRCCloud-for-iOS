@interface ICLogInViewController:UITableViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
	BOOL isLoggingIn;
	NSString *logInError;
}
-(void)logIn;
@end
