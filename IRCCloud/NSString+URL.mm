#import "NSString+URL.h"

@implementation NSString (URL)
-(NSString *)URLEncodedString{
	return (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)self,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
}
@end
