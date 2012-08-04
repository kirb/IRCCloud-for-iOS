#import "ICGlobal.h"
#import "ADTableViewInputCell.h"

// based on http://stackoverflow.com/a/1985461
@implementation ADTableViewInputCell
@synthesize textField;
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuse{
	if((self=[super initWithStyle:style reuseIdentifier:reuse])){
		textField=[[[UITextField alloc]initWithFrame:CGRectMake(isPad?116:125,11,isPad?360:185,20)]autorelease];
		textField.clearsOnBeginEditing=NO;
		textField.textAlignment=UITextAlignmentLeft;
		textField.returnKeyType=UIReturnKeyDone;
		textField.autoresizingMask=UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
		textField.backgroundColor=[UIColor clearColor];
		textField.textColor=[UIColor colorWithRed:.22 green:.33 blue:.53 alpha:1];
		textField.font=[UIFont systemFontOfSize:16];
		self.accessoryView=textField;
	}
	return self;
}
-(void)dealloc{
	[textField release];
	[super dealloc];
}
-(void)layoutSubviews{
	[super layoutSubviews];
	((CGRect)self.textLabel.frame).size.width=isPad?108:118;
	[self bringSubviewToFront:textField];
}
@end

