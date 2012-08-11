@interface ICRequest:NSObject{
	id delegate;
	SEL selector;
}
+(ICRequest *)requestWithPage:(NSString *)page parameters:(NSString *)params alpha:(BOOL)alpha delegate:(id)delegate selector:(SEL)selector;
-(ICRequest *)initWithPage:(NSString *)page parameters:(NSString *)params alpha:(BOOL)alpha delegate:(id)delegate selector:(SEL)selector;
+(ICRequest *)requestWithPage:(NSString *)page parameters:(NSString *)params delegate:(id)delegate selector:(SEL)selector;
-(ICRequest *)initWithPage:(NSString *)page parameters:(NSString *)params delegate:(id)delegate selector:(SEL)selector;
@end
