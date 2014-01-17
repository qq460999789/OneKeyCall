//
//  ContactsDetailController.m
//  OneKeyCall
//
//  Created by swhl on 13-7-5.
//  Copyright (c) 2013年 sprite. All rights reserved.
//

#import "ContactsDetailController.h"
#import "NSStringAdditions.h"
#import "HTTPServer.h"
#include <dispatch/base.h>
#include "NSData+Base64.h"
#import <QuartzCore/QuartzCore.h>


@interface ContactsDetailController ()

@end

@implementation ContactsDetailController{
    HTTPServer *httpServer ;
    BOOL serverIsRunning;
    UIBackgroundTaskIdentifier  bgTask;
    
    NSMutableString *userName;
//    NSString *mobile;
    NSData *iconImageData;
    
    NSMutableArray *mobileArray;
    
    
    UIImageView *picture;
    UITextField *userNameLabel;
    UILabel *mobileLabel;
    
    UIScrollView *mScrollView;


    UIImagePickerController *imagePickerController;
}

@synthesize person = _person;


- (void)dealloc
{
    [userName release];
    [mobileArray release];
    [iconImageData release];
    [mScrollView release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.view.bounds = CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height);
    }
    
    self.title = @"一键拨号";
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [temporaryBarButtonItem release];

    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    createBtn.frame = CGRectMake(20, 100, 280, 40);
    [createBtn addTarget:self action:@selector(createIcon:) forControlEvents:UIControlEventTouchUpInside];
    [createBtn setTitle:@"创建快捷图标" forState:UIControlStateNormal ] ;
    [createBtn setBackgroundImage:[UIImage imageNamed:@"images/btn_bg_n"] forState:UIControlStateNormal];
    [createBtn setBackgroundImage:[UIImage imageNamed:@"images/btn_bg_p"] forState:UIControlStateHighlighted];
    createBtn.titleLabel.textColor = [UIColor blackColor];
    createBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [createBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [createBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.view addSubview:createBtn];
    
    
    picture = [[UIImageView alloc]initWithFrame:CGRectMake(60, 20, 58, 58)];
    picture.layer.cornerRadius = 5;
    picture.layer.masksToBounds = YES;
    picture.image = [UIImage imageWithData:iconImageData];
    [self.view addSubview:picture];
    [picture release];
    picture.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showSelectPictureAction:)];
    gr.numberOfTapsRequired = 1;
    gr.numberOfTouchesRequired = 1;
    [picture addGestureRecognizer:gr];
    

    userNameLabel = [[UITextField alloc]initWithFrame:CGRectMake(130, 25, 200, 30)];
    userNameLabel.text = userName;
    userNameLabel.textColor = [UIColor blueColor];
    userNameLabel.font = [UIFont systemFontOfSize:22];
//    userNameLabel.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:userNameLabel];
    [userNameLabel release];
    
    mobileLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 50, 200, 30)];
    mobileLabel.text = mobileArray[0];
    mobileLabel.textColor = [UIColor blueColor];
    mobileLabel.font = [UIFont systemFontOfSize:20];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selMobile:)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    [mobileLabel addGestureRecognizer:tgr];
    mobileLabel.userInteractionEnabled = YES;
    
    [self.view addSubview:mobileLabel];
    [mobileLabel release];

    
    UIView *selectIconView =  [[UIScrollView alloc]initWithFrame:CGRectMake(0 ,160, 320, self.view.frame.size.height-160-44)];
//    selectIconView.backgroundColor = [UIColor colorWith ];
    
    mScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0 , 0, 320, self.view.frame.size.height-160-44)];
    mScrollView.contentSize = CGSizeMake(320*2, mScrollView.frame.size.height);
    mScrollView.pagingEnabled = YES;
    [selectIconView addSubview:mScrollView];
    [mScrollView release];
    
    
    [self.view addSubview:selectIconView];
    [selectIconView release];

}

-(void)viewDidAppear:(BOOL)animated{
    __block typeof(self) bself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [bself loadScrollViewImage];
        
    });
}

-(void)selMobile:(UITapGestureRecognizer*)tgr{
    if (mobileArray.count>1) {
        UIActionSheet *mobileActionSheet = [[UIActionSheet alloc]init] ;
        mobileActionSheet.delegate = self;
        mobileActionSheet.tag = 1;
        
        for(NSString *m in mobileArray){
            [mobileActionSheet addButtonWithTitle:m];
        }
        
        mobileActionSheet.cancelButtonIndex = [mobileActionSheet addButtonWithTitle:@"取消"];
        
        [mobileActionSheet showInView:self.view];
    }
}

-(void)loadScrollViewImage{
    NSLog(@"---");
    int space = 5;
    int x = 0;
    for (int i=0; i<4; i++) {
        for (int j=0; j<10; j++) {
            if(j==0){
                x = space;
            }else if(j%5==0) {
                x += space + space + 58;
            }else{
                x += space + 58;
            }   

            UIButton *iconBtn =[UIButton buttonWithType:UIButtonTypeCustom];
            [iconBtn setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"images/icon/head_%d_%d" , i,j]] forState:UIControlStateNormal];
            iconBtn.frame = CGRectMake(x , space + (space+58)*i, 58, 58);
            iconBtn.layer.cornerRadius = 5;
            iconBtn.layer.masksToBounds = YES;
            iconBtn.tag = 10000 + i*100+j;
            [iconBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            [mScrollView addSubview:iconBtn];
            
        }
    }
    
    NSLog(@"---");
}

-(void)buttonClick:(id)sender{
    NSLog(@"---%d---%d---%d",((UIButton*)sender).tag,((UIButton*)sender).tag%1000 /100,((UIButton*)sender).tag%100);
    int i = ((UIButton*)sender).tag%1000 / 100;
    int j = ((UIButton*)sender).tag%100;
    picture.image = [UIImage imageNamed:[NSString stringWithFormat:@"images/icon/head_%d_%d", i,j]];
}

-(void)showSelectPictureAction:(UITapGestureRecognizer*)gr{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]init];
    actionSheet.tag = 0;
    
    [actionSheet addButtonWithTitle:@"照相机"];
    [actionSheet addButtonWithTitle:@"图片库"];
//    [actionSheet addButtonWithTitle:@"自带图"];
    [actionSheet addButtonWithTitle:@"取消"];
    
    actionSheet.cancelButtonIndex = 2;
    
    actionSheet.delegate = self;
    
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (actionSheet.tag) {
        case 0:
        {
            imagePickerController = [[UIImagePickerController alloc] init];
            switch (buttonIndex) {
                case 0:
                    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                default:
                    return;
                
            }
           
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            
            
            [self presentModalViewController:imagePickerController animated:YES];
            [imagePickerController release];
            break;
        }
        case 1:
            mobileLabel.text = [actionSheet buttonTitleAtIndex:buttonIndex];
            break;
        default:
            break;
    }

}
-(void)selectPicture:(UITapGestureRecognizer*)gr{

    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        
    }];
    
    [imagePickerController release];
    
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    picture.image = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.01)] ;
    [imagePickerController dismissModalViewControllerAnimated:YES];
}

-(void)setPerson:(ABRecordRef)person{
    _person = person;
    
    
    NSString *first =(NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    NSString *last = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    
    userName = [[NSMutableString alloc]initWithCapacity:0];
    if (last)
        [userName appendString:last];
    if(first)
        [userName appendString:first];

    [userName retain];
    
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    mobileArray = [[NSMutableArray alloc]initWithCapacity:0];
    if ((phone != nil)&&ABMultiValueGetCount(phone)>0) {
        for (int m = 0; m < ABMultiValueGetCount(phone); m++) {
            [mobileArray addObject:[(NSString *)ABMultiValueCopyValueAtIndex(phone, m) autorelease]];
        }
    }else{
        mobileArray[0] = @"";
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
        iconImageData = UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(),0.01);
        

    }else{
        iconImageData = UIImageJPEGRepresentation([UIImage imageNamed:@"images/person_headpic"], 1) ;
    }

    [iconImageData retain];
    
    
}

-(void)createIcon:(id)sender{
    [self setupServer];
    [self openService];
    
    [self createIcon];
}


-(void)createIcon{
    NSString *tempIndexPath =[NSString stringWithFormat:@"%@/index.html", [httpServer documentRoot]];
//    tempIndexPath = [[NSBundle mainBundle] pathForResource:@"/docroot/index" ofType:@"html"];
    NSString *phonePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"docroot/phone.html"];
    NSString *indextemplatePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] bundlePath], @"docroot/index_template.html"];
    
    NSLog(@"-----1-----%@", tempIndexPath);
    

    
    NSString *phoneString = [NSString stringWithContentsOfFile:phonePath encoding:NSUTF8StringEncoding error:NULL];
    NSString *indextemplateString = [NSString stringWithContentsOfFile:indextemplatePath encoding:NSUTF8StringEncoding error:NULL];
    
    //替换iconimage
    phoneString = [phoneString stringByReplacingOccurrencesOfString:_ICONIMAGE withString:[UIImageJPEGRepresentation(picture.image, 1) base64Encoding]];
    
    //替换过startimage
    //    UIImage *startupImage = [UIImage imageNamed:@"images/startupImage.png"];
    //    NSData *startupData = UIImageJPEGRepresentation(startupImage,1.0);
    //    NSString *startupString = [startupData base64Encoding];
    NSString *startupString =@"iVBORw0KGgoAAAANSUhEUgAAAUAAAAHMCAMAAACTPIE7AAAAA1BMVEUAAACnej3aAAACnElEQVR4Ae3QMQEAAADCoPVPbQlPiEBhwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwIABAwYMGDBgwICB/8AAQOoAAV1lLf4AAAAASUVORK5CYII=";
    phoneString = [phoneString stringByReplacingOccurrencesOfString:_STARTIMAGE withString:startupString];
    
    //替换username
    phoneString = [phoneString stringByReplacingOccurrencesOfString:_USERNAME  withString:userName];
    
    //替换电话号码
    phoneString = [phoneString stringByReplacingOccurrencesOfString:_MOBILE  withString:mobileLabel.text];
    
    //替换index.html中的跳转地址
    indextemplateString = [indextemplateString stringByReplacingOccurrencesOfString:_HTML withString:[phoneString URLEncodedString]];
    
    
    NSLog(@"size----%d",indextemplateString.length);
    //将index.html在写入回去
    BOOL a = [[indextemplateString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:tempIndexPath atomically:YES];
    NSLog(@"2=====%d",a);
    

//	
//    NSString *srcPath = [[NSBundle mainBundle] pathForResource:@"/docroot/p" ofType:@"plist"];
//    NSDictionary *x = @{@"1":@"8",@"2":@"7",@"3":@"56",@"4":@"5"};
//    BOOL aaa = [x writeToFile:srcPath atomically:YES];
//    NSLog(@"-----aaa-----%d", aaa);
//    
//    NSString *srcPathx = [[NSBundle mainBundle] pathForResource:@"x" ofType:@"plist"];
//    NSDictionary *xx = @{@"1":@"8",@"2":@"7",@"3":@"56",@"4":@"5"};
//    BOOL aaaxxx = [xx writeToFile:srcPathx atomically:YES];
//    NSLog(@"-----aaaxxxx-----%d", aaaxxx);
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://127.0.0.1:13256/index.html"]];
    [self execBackrgoundMethod];
}


-(void)execBackrgoundMethod
{
    
    UIApplication* app = [UIApplication sharedApplication];
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             0), ^{
       
        double delayInSeconds = 5.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self closeService];
            
            [app endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        });
        
        
    });
}


-(void)setupServer{
    httpServer = [[HTTPServer alloc] init];
    [httpServer setType:@"_http._tcp"];
    [httpServer setPort:13256];
    [httpServer setName:@"CocoaWebResouceManager"];
    [httpServer setupBuiltInDocroot];
    
}

-(void)openService{
    NSError *error;
    //开启
    serverIsRunning = [httpServer start:&error];
    if(!serverIsRunning){
        NSLog(@"Error starting HTTP server :%@",error);
        return;
    }
}
-(void)closeService{
    
    [httpServer stop];
    [httpServer release];
    serverIsRunning = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}

@end
