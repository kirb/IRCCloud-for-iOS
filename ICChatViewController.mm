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
	self.view=[[[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen]applicationFrame]]autorelease];
	self.view.backgroundColor=[UIColor whiteColor];
	bottomBar=[[ICBottomBar alloc]init];
	self.toolbarItems=[NSArray arrayWithObject:bottomBar];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation{
	NSLog(@",,, = %@",self.navigationItem.leftBarButtonItem);
	return YES;
}
@end
