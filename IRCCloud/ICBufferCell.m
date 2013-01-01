//
//  ICBufferCell.m
//  IRCCloud
//
//  Created by Aditya KD on 01/01/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import "ICBufferCell.h"

@interface ICBufferCell ()
{
    UILabel *_senderLabel;
    UILabel *_messageLabel;
}
- (void)setUp;
@end

@implementation ICBufferCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)setUp
{
    _senderLabel  = [[UILabel alloc] initWithFrame:(CGRect){self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, 20, 18}];
    _messageLabel = [[UILabel alloc] initWithFrame:self.contentView.frame];
    
    _senderLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    _messageLabel.numberOfLines = 20;
    
    [self.contentView addSubview:_senderLabel];
    [self.contentView addSubview:_messageLabel];
}

- (void)setMessage:(NSString *)message
{
    _messageText = message;
    NSInteger numberOfSpcaes = ceilf([_senderText sizeWithFont:[UIFont boldSystemFontOfSize:15.f] constrainedToSize:_senderLabel.frame.size].width);
    NSMutableString *spaces = [NSMutableString stringWithString:@""];
    for (NSInteger i = 0; i <= numberOfSpcaes; i++) {
        [spaces appendString:@" "];
    }
    _messageText = [spaces stringByAppendingString:_messageText];
    _messageLabel.text = _messageText;
}

- (void)setSenderText:(NSString *)senderText
{
    _senderText = senderText;
    _senderLabel.text = _senderText;
}

@end
