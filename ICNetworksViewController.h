#import "ICGlobal.h"
#import "ICBuffer.h"

@interface ICNetworksViewController:UITableViewController<UIPopoverControllerDelegate>{
	NSMutableArray *buffers;
	BOOL isShowingSettings;
	UIPopoverController *settingsPopover;
}
@property(retain) NSMutableArray *buffers;
-(void)showLogIn;
@end
