#import "ICGlobal.h"
#import "ICBottomBar.h"

@implementation ICBottomBar
-(ICBottomBar *)initWithFrame:(CGRect)frame{
	frame.size.height=32;
	if((self=[super initWithFrame:frame]))self.backgroundColor=[UIColor lightGrayColor];
	return self;
}
@end
