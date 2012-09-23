#import "ICGlobal.h"
#import "ICNetworksViewController.h"
#import "ICChatViewController.h"
#import "ICChatRequest.h"

@interface ICApplication:UIApplication<UIApplicationDelegate,UISplitViewControllerDelegate>{
	UIWindow *window;
	UISplitViewController *viewController;
	ICNetworksViewController *sidebar;
	ICChatViewController *main;
	UIViewController *sidebarNavController;
	UIViewController *mainNavController;
	NSString *cookie;
	BOOL userIsOnAlpha;
	ICChatRequest *connection;
	NSMutableDictionary *servers;
}
-(void)connect;
@property(nonatomic,retain) UIWindow *window;
@property(nonatomic,retain) NSString *cookie;
@property(assign) BOOL userIsOnAlpha;
@property(nonatomic,retain) ICChatRequest *connection;
@property(nonatomic,retain) NSMutableDictionary *servers;
@end
