//
//  ContactsDetailController.h
//  OneKeyCall
//
//  Created by swhl on 13-7-5.
//  Copyright (c) 2013年 sprite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsDetailController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@property (nonatomic) ABRecordRef person;

@end
