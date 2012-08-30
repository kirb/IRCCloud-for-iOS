#import "ICGlobal.h"
#import "ICChatViewController.h"
#import "ICBuffer.h"

@implementation ICChatViewController
@synthesize buffer;
-(ICChatViewController *)initWithBuffer:(ICBuffer *)buffer1{
	if((self=[super init]))self.buffer=buffer1;
	return self;
}
-(void)loadView{
	self.view=[[[UIWebView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]]autorelease];
	self.view.backgroundColor=[UIColor whiteColor];
	self.title=@"";
	textField=[[UITextField alloc]init];
	textField.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self setToolbarItems:[NSArray arrayWithObject:
		[[UIBarButtonItem alloc]initWithCustomView:textField]
	] animated:NO];
	self.navigationController.toolbarHidden=NO;
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
	return YES;
}
@end
