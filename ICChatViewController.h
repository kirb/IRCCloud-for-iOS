#import "ICBuffer.h"
#import "ICBottomBar.h"

@interface ICChatViewController:UIViewController{
	ICBuffer *buffer;
	UIScrollView *scrollView;
	ICBottomBar *bottomBar;
}
-(ICChatViewController *)initWithBuffer:(ICBuffer *)buffer;
@property(retain) ICBuffer *buffer;
@end
