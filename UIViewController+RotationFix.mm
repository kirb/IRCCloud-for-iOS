#import "UIViewController+RotationFix.h"

//from http://stackoverflow.com/a/4098400

@implementation UIViewController (RotationFix)
-(UIViewController *)parent{
	return self.parentViewController;
}    
-(void)setParent:(UIViewController *)parent{
	[self setValue:parent forKey:@"_parentViewController"];
}
@end
        
