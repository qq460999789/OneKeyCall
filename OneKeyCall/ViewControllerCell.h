
//  OneKeyCall
//
//  Created by swhl on 13-7-8.
//  Copyright (c) 2013年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewControllerCell : UITableViewCell

@property (nonatomic) ABRecordRef person;
@property (nonatomic,retain) UIImageView *picture;
@property (nonatomic,retain) UILabel *nameLabel;
@property (nonatomic,retain) UILabel *mobileLabel;

@end
