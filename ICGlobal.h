extern "C" UIImage *_UIImageWithName(NSString *);

typedef enum{
	UIModalPresentationFullScreen=0,
	UIModalPresentationPageSheet,
	UIModalPresentationFormSheet,
	UIModalPresentationCurrentContext,
} UIModalPresentationStyle;

typedef enum{
	UIAlertViewStyleDefault=0,
	UIAlertViewStyleSecureTextInput,
	UIAlertViewStylePlainTextInput,
	UIAlertViewStyleLoginAndPasswordInput
} UIAlertViewStyle;

enum{
	UIPopoverArrowDirectionUp=1UL<<0,
	UIPopoverArrowDirectionDown=1UL<<1,
	UIPopoverArrowDirectionLeft=1UL<<2,
	UIPopoverArrowDirectionRight=1UL<<3,
	UIPopoverArrowDirectionAny=UIPopoverArrowDirectionUp|UIPopoverArrowDirectionDown|UIPopoverArrowDirectionLeft|UIPopoverArrowDirectionRight,
	UIPopoverArrowDirectionUnknown=NSUIntegerMax
};
typedef NSUInteger UIPopoverArrowDirection;

typedef enum{
	ICMessageTypeMessage,
	ICMessageTypeMe
} ICMessageType;

typedef enum{
	ICServerStatusUnknown,
	ICServerStatusQueued,
	ICServerStatusConnecting,
	ICServerStatusConnected,
	ICServerStatusJoining,
	ICServerStatusReady,
	ICServerStatusQuitting,
	ICServerStatusDisconnected,
	ICServerStatusPoolUnavailable,
	ICServerStatusWaiting,
	ICServerStatusRetrying
} ICServerStatus;

typedef enum{
	ICBufferTypeUnknown,
	ICBufferTypeConsole,
	ICBufferTypeChannel,
	ICBufferTypeConversation
} ICBufferType;

typedef enum{
	ICBufferSecurityUnknown,
	ICBufferSecurityPublic,
	ICBufferSecurityPrivate,
	ICBufferSecuritySecret
} ICBufferSecurity;

#define ICGetServer(server) [[ICApp servers]objectForKey:[NSString stringWithFormat:@"%i",server]]
#define ICGetBuffer(server,buffer) [ICGetServer(server).buffers objectForKey:[NSString stringWithFormat:@"%i",buffer]]

@interface UIDevice (iPad)
-(BOOL)isWildcat;
@end

@interface UIViewController (iPad)
@property(nonatomic,assign) UIModalPresentationStyle modalPresentationStyle;
@property(nonatomic,readwrite) CGSize contentSizeForViewInPopover;
@end

@protocol UISplitViewControllerDelegate;
@protocol UIPopoverControllerDelegate;

@interface UISplitViewController:UIViewController
@property(nonatomic,copy) NSArray *viewControllers;
@property(nonatomic,assign) id<UISplitViewControllerDelegate> delegate;
@end

@interface UIPopoverController:UIViewController
-(UIPopoverController *)initWithContentViewController:(UIViewController *)ctrl;
-(void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)directions animated:(BOOL)animated;
-(void)dismissPopoverAnimated:(BOOL)animated;
@property(nonatomic,assign) id<UIPopoverControllerDelegate> delegate;
@end

@protocol UISplitViewControllerDelegate
@optional
-(void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController;
-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation;
-(void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc;
-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button;
@end

@protocol UIPopoverControllerDelegate
@optional
-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
-(BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController;
@end

@interface NSJSONSerialization:NSObject
+(id)JSONObjectWithData:(NSData *)data options:(int)flags error:(NSError **)error;
@end

@interface UIAlertView (iOS5)
-(UITextField *)textFieldAtIndex:(NSInteger)index;
@property(nonatomic,assign) UIAlertViewStyle alertViewStyle;
@end

@interface UINavigationBar (iOS5)
+(UINavigationBar *)appearance;
@end

#define __(key) [[NSBundle mainBundle]localizedStringForKey:key value:key table:@"IRCCloud"]
#define version @"0.0.1"
#define isPad ([[UIDevice currentDevice]respondsToSelector:@selector(isWildcat)]?[[UIDevice currentDevice]isWildcat]:NO)
#define prefpath @"/var/mobile/Library/Preferences/ws.hbang.irccloud.plist"
#define ICApp (ICApplication *)[UIApplication sharedApplication]
#define betaURL @"irccloud.com"
#define alphaURL @"alpha.irccloud.com"
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:a]
