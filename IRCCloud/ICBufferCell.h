//
//  ICBufferCell.h
//  IRCCloud
//
//  Created by Aditya KD on 01/01/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface ICBufferCell : UITableViewCell <TTTAttributedLabelDelegate>

@property (nonatomic, strong, readonly) TTTAttributedLabel *attributedLabel;

@end
