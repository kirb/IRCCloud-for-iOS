#import "ICGlobal.h"
#import "ICNetworksViewController.h"
#import "ICChatViewController.h"

@interface ICApplication:UIApplication<UIApplicationDelegate,UISplitViewControllerDelegate>{
	UIWindow *window;
	UISplitViewController *viewController;
	ICNetworksViewController *sidebar;
	ICChatViewController *main;
	UIViewController *sidebarNavController;
	UIViewController *mainNavController;
}
@property(nonatomic,retain) UIWindow *window;
@end
