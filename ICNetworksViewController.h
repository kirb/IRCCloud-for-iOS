#import "ICBuffer.h"

@interface ICNetworksViewController:UITableViewController{
	NSMutableArray *buffers;
	BOOL hasCookie;
}
@property(retain) NSMutableArray *buffers;
@property(assign) BOOL hasCookie;
@end
