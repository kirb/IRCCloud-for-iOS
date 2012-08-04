%hook UISplitViewController
%new -(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
	return YES;
}
%end
