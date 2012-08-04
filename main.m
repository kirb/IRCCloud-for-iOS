int main(int argc,char **argv){
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	int ret=UIApplicationMain(argc,argv,@"ICApplication",@"ICApplication");
	[p drain];
	return ret;
}
