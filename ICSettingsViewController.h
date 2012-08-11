#import "ICGlobal.h"

@interface ICSettingsViewController:UITableViewController<UITableViewDataSource,UITableViewDelegate>{
	UIPopoverController *popoverController;
}
@property(retain,nonatomic) UIPopoverController *popoverController;
@end
