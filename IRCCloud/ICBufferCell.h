//
//  ICBufferCell.h
//  IRCCloud
//
//  Created by Aditya KD on 01/01/13.
//  Copyright (c) 2013 HASHBANG Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICBufferCell : UITableViewCell

// this property should be set before setting the next two.
@property (nonatomic, assign) BOOL shouldItalicize;

@property (nonatomic, copy) NSString *senderText;
@property (nonatomic, copy) NSString *messageText;

@end
