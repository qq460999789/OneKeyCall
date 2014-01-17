//
//  ViewControllerCell.m
//  OneKeyCall
//
//  Created by swhl on 13-7-8.
//  Copyright (c) 2013年 sprite. All rights reserved.
//

#import "ViewControllerCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ViewControllerCell

@synthesize person = _person;
@synthesize picture = _picture;
@synthesize nameLabel = _nameLabel;
@synthesize mobileLabel = _mobileLabel;

- (void)dealloc
{
    self.picture = nil;
    self.nameLabel = nil;
    self.mobileLabel = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}

-(void)initView{
    self.nameLabel =  [[UILabel alloc] initWithFrame:CGRectMake(55, 10, 230, 19)];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.font = [UIFont systemFontOfSize:18];
    [self addSubview:self.nameLabel];
    [self.nameLabel release];

    //手机号
    self.mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 140, 19)];
    self.mobileLabel.backgroundColor = [UIColor clearColor];
    self.mobileLabel.textColor = [UIColor grayColor ];
    self.mobileLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.mobileLabel];
    [self.mobileLabel release];
    
    //头像
    self.picture = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 45, 45)];
    self.picture.layer.cornerRadius = 5;
    self.picture.layer.masksToBounds = YES;
    

    [self.contentView addSubview:self.picture];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

-(void)setPerson:(ABRecordRef)person{
    _person = person;
    
    
    NSString *first =(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *last = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);

    NSMutableString *name = [[NSMutableString alloc]initWithCapacity:0];
    if (last)
        [name appendString:last];
    if(first)
        [name appendString:first];
    
    self.nameLabel.text = name;
    [name release];
    
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if ((phone != nil)&&ABMultiValueGetCount(phone)>0) {
        for (int m = 0; m < ABMultiValueGetCount(phone); m++) {
            NSString * aPhone = [(NSString *)ABMultiValueCopyValueAtIndex(phone, m) autorelease];
//            NSString * aLabel = [(NSString *)ABMultiValueCopyLabelAtIndex(phone, m) autorelease];
            self.mobileLabel.text = aPhone;
            break;
        }
    }else{
        self.mobileLabel.text = @"";
    }
    

    //读取照片信息
    NSData *imageData = (NSData *)ABPersonCopyImageData(person);
    if (imageData) {
        UIImage *resImage = [UIImage imageWithData:imageData];
        CGFloat size = MIN(resImage.size.width, resImage.size.height);
        CGRect rect = CGRectMake((resImage.size.width-size)/2, (resImage.size.height-size)/2, size, size);
        
        
        CGImageRef ref = CGImageCreateWithImageInRect(resImage.CGImage, rect);
        
        rect = CGRectMake(0, 0, size, size);
        UIGraphicsBeginImageContext(rect.size);
        [[UIImage imageWithCGImage: ref] drawInRect:rect];
        
        CGImageRelease(ref);
        self.picture.image = UIGraphicsGetImageFromCurrentImageContext();
        
        
//        UIImage *myImage = [UIImage imageWithData:imageData];
//        CGSize newSize = CGSizeMake(55, 55);
//        UIGraphicsBeginImageContext(newSize);
//        [myImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImage\Context();//上诉代码实现图片压缩，可根据需要选择，现在是压缩到55*55
        
//        imageData = UIImagePNGRepresentation(newImage);
    
//        self.picture.image = [UIImage imageWithData:imageData];
    }else{
        self.picture.image = [UIImage imageNamed:@"images/person_headpic"];
    }

}



@end
