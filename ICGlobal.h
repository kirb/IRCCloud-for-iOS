extern "C" UIImage *_UIImageWithName(NSString *);

typedef enum{
	UIModalPresentationFullScreen=0,
	UIModalPresentationPageSheet,
	UIModalPresentationFormSheet,
	UIModalPresentationCurrentContext,
} UIModalPresentationStyle;

@interface UIDevice (iPad)
-(BOOL)isWildcat;
@end

@interface UIViewController (iPad)
@property(nonatomic,assign) UIModalPresentationStyle modalPresentationStyle;
@end

@protocol UISplitViewControllerDelegate;

@interface UISplitViewController:UIViewController
@property(nonatomic,copy) NSArray *viewControllers;
@property(nonatomic,assign) id<UISplitViewControllerDelegate> delegate;
@end

@interface UIPopoverController:UIViewController
@end

@protocol UISplitViewControllerDelegate
@optional
-(void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController;
-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation;
-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc;
-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button;
@end

#define __(key) [[NSBundle mainBundle]localizedStringForKey:key value:key table:@"IRCCloud"]
#define version @"0.0.1 Alpha"
#define isPad ([[UIDevice currentDevice]respondsToSelector:@selector(isWildcat)]?[[UIDevice currentDevice]isWildcat]:NO)
