//
//  ICAddViewController.m
//  IRCCloud
//
//  Created by Adam D on 22/11/12.
//  Copyright (c) 2012 Adam D. All rights reserved.
//

#import "ICAddViewController.h"

@interface ICAddViewController ()

@end

@implementation ICAddViewController

-(void)viewDidLoad {
	[super viewDidLoad];
	[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].backgroundView = [[[UIView alloc] init] autorelease];
}

@end
