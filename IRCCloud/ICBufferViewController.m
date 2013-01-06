//
//  ICBufferViewController.m
//  IRCCloud
//
//  Created by Adam D on 14/10/12.
//  Copyright (c) 2012 HASHBANG Productions. All rights reserved.
//

#import "ICBufferViewController.h"
#import "ICMasterViewController.h"
#import "ICAppDelegate.h"
#import "ICBufferCell.h"

#define kLastRowIndex [NSIndexPath indexPathForRow:self.channel.buffer.count-1 inSection:0]

@interface ICBufferViewController ()
{
    NSIndexPath *_lastVisibleIndexPath;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (assign, nonatomic) NSInteger rowCount;
@property (strong, nonatomic) NSMutableDictionary *attributedMessages;

- (void)updateRowCount;
@end

@implementation ICBufferViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setChannel:(ICChannel *)channel
{
    self.rowCount = channel.buffer.count;
    channel.delegate = self;
    _channel = channel;
}

#pragma mark - Managing the detail item

- (void)configureView
{
	((ICAppDelegate *)[UIApplication sharedApplication].delegate).currentBuffer = self;
    self.navigationItem.title = self.channel.name;
    
    if (!_textField) {
        CGFloat width = 0.f;
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            width = [UIScreen mainScreen].bounds.size.width - 20.f;
        }
        else if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            width = [UIScreen mainScreen].bounds.size.height - 20.f;
        }
		_textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
		_textField.autoresizingMask   = UIViewAutoresizingFlexibleWidth;
		_textField.borderStyle        = UITextBorderStyleRoundedRect;
        _textField.delegate           = self;
        
        
        [self setToolbarItems:@[[[UIBarButtonItem alloc] initWithCustomView:_textField]] animated:NO];
        [self.navigationController setToolbarHidden:NO animated:NO];
	}
    
    // this toolbar will be set as the input accessory view
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 40.f)];
    
    _realTextField                          = [[UITextField alloc] initWithFrame:_textField.frame];
    _realTextField.autoresizingMask         = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _realTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _realTextField.borderStyle              = UITextBorderStyleRoundedRect;
    _realTextField.returnKeyType            = UIReturnKeySend;
    _realTextField.delegate                 = self;
    
    [_toolbar setItems:@[[[UIBarButtonItem alloc] initWithCustomView:_realTextField]] animated:YES];
    _textField.inputAccessoryView = _toolbar;
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
    if (isPad){
        if (self.channel.buffer.count > 0) {
            [self.tableView scrollToRowAtIndexPath:kLastRowIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            [self.tableView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0.4];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
	[self configureView];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (isPad && ![[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"]) {
		[(ICMasterViewController *)[self.splitViewController.viewControllers[0] topViewController] performSelector:@selector(showLogIn) withObject:nil afterDelay:0.3];
	}
    if (self.channel.buffer.count > 0)
        [self.tableView scrollToRowAtIndexPath:kLastRowIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self.tableView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0.5];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_realTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    if (self.channel.buffer.count > 1)
        [self.tableView scrollToRowAtIndexPath:kLastRowIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [_realTextField becomeFirstResponder];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.navigationController setToolbarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text.length > 0)
        [self.channel sendMessage:textField.text];
    else {
        [textField resignFirstResponder];
    }
    textField.text = @"";
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.channel.buffer) {
        return self.rowCount;
    }
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.attributedMessages) {
        // create the instance of the dict that will hold the attributed strings.
        self.attributedMessages = [[NSMutableDictionary alloc] init];
    }
    
    if ([tableView respondsToSelector:@selector(registerClass:forCellReuseIdentifier:)]) {
        [tableView registerClass:[ICBufferCell class] forCellReuseIdentifier:@"BufferCell"];
    }
    
    ICBufferCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BufferCell"];
    
    if (self.attributedMessages[@(indexPath.row)]) {
        // check if the attributed string is available for a row, and use that instead
        // redrawing every time is /very/ performance intensive. A noticeable lag is seen on a 3rd gen iPad, too.
        cell.attributedLabel.text = self.attributedMessages[@(indexPath.row)];
        return cell;
    }
    
    NSString *nick = (self.channel.buffer[indexPath.row])[@"from"];
    NSString *message = [self.channel buffer][indexPath.row][@"msg"];
    
    if ([(self.channel.buffer[indexPath.row])[@"type"] isEqualToString:@"buffer_me_msg"]) {
        nick = [@"• " stringByAppendingString:nick];
        // This is temporary, we need a more elegant solution than this.
    }
    
    NSString *text = [[nick stringByAppendingString:@" "] stringByAppendingString:message];
    cell.attributedLabel.numberOfLines = 20;
    
    [cell.attributedLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:nick options:NSCaseInsensitiveSearch];
        UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:14];
        
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }
        return mutableAttributedString;
    }];
    
    // set the attributed string to the indexPath.row key.
    // Eventually, I shall add checks to make sure the dictionary doesn't grow so big that iOS kills the app because of memory usage.
    self.attributedMessages[@(indexPath.row)] = cell.attributedLabel.attributedText;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = [self.channel.buffer[indexPath.row][@"from"] stringByAppendingString:self.channel.buffer[indexPath.row][@"msg"]];
    
    CGFloat width = 0.f;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        width = [UIScreen mainScreen].bounds.size.height;
    }
    else if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        width = [UIScreen mainScreen].bounds.size.width;
    }
	CGSize cellSize = [text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    
    return cellSize.height + 3.f;
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
#pragma mark - Split view
- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (self.channel.buffer.count > 0)
            [self.tableView scrollToRowAtIndexPath:kLastRowIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [self.tableView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0.4];
    });
}
- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = L(@"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)updateRowCount
{
    self.rowCount = self.channel.buffer.count;
}

#pragma mark - ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _lastVisibleIndexPath = [self.tableView indexPathForCell:[[self.tableView visibleCells] lastObject]];
}

#pragma mark - ICBuffer's notifs
static BOOL isUpdating = NO;
- (void)addedMessageToBuffer:(ICBuffer *)buffer
{
    while (isUpdating) {
        continue;
    }
    NSLock *lock = [[NSLock alloc] init];
    [lock lock];
    if (!isUpdating)
        [self updateRowCount];
    isUpdating = YES;
    
    NSArray *bufferCopy = self.channel.buffer.copy;
    
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[bufferCopy indexOfObject:bufferCopy.lastObject] inSection:0]]
                          withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView endUpdates];
    
    if ((_lastVisibleIndexPath.row + 1) == kLastRowIndex.row) // if the lastVisibleRow + 1 is equal to the newly added row, then scroll to that row. Simple enough.
        [self.tableView scrollToRowAtIndexPath:kLastRowIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    isUpdating = NO;
    [lock unlock];
}
@end
