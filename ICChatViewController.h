#import "ICBuffer.h"

@interface ICChatViewController:UIViewController{
	ICBuffer *buffer;
	UITextField *textField;
}
-(ICChatViewController *)initWithBuffer:(ICBuffer *)buffer;
@property(retain) ICBuffer *buffer;
@end
