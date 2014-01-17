//
//  ViewController.m
//  OneKeyCall
//
//  Created by swhl on 13-7-3.
//  Copyright (c) 2013年 sprite. All rights reserved.
//

#import "ViewController.h"
#import "ContactsDetailController.h"
#import "ContactsLogic.h"
#import "ViewControllerCell.h"
#import "UIFolderTableView.h"
#import "SubCateViewController.h"
#import "NSStringAdditions.h"

@interface ViewController (){
    
}

@end

@implementation ViewController{
    UIFolderTableView *mTableView;
    NSMutableDictionary *contactsDictionary;
    NSArray *contactsDictionaryAllKeys;
    UIWebView *webView;
    ABRecordRef person;
}

- (void)dealloc
{
    [mTableView release];
    [contactsDictionary release];
    [contactsDictionaryAllKeys release];
    [webView release];
    
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated{
    dispatch_async(dispatch_get_current_queue(), ^{
        
            ContactsLogic *contactsLogic = [Singleton getInstance:[ContactsLogic class]];
            contactsDictionary = [[contactsLogic loadContacts]retain];
            contactsDictionaryAllKeys = [[contactsDictionary.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                
                if ([(NSString*)obj1 hasPrefix:@"#"]&&![(NSString*)obj2 hasPrefix:@"#"]) {
                    return NSOrderedDescending;
                }else if(![(NSString*)obj1 hasPrefix:@"#"]&&[(NSString*)obj2 hasPrefix:@"#"]){
                    return NSOrderedAscending;
                }else{
                    return [(NSString*)obj1 caseInsensitiveCompare:(NSString*)obj2];
                }
            }]retain];
            
            [mTableView reloadData];
      });
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.view.bounds = CGRectMake(0, -64, self.view.frame.size.width, self.view.frame.size.height);
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-20);
    }
    
    self.title = @"一键拨号";


    webView = [[UIWebView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:webView];

 
        mTableView = [[UIFolderTableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-44)];

    
    mTableView.delegate = self;
    mTableView.dataSource = self;
    [self.view addSubview:mTableView];

}


#pragma mark - UITableViewDelegate
- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(!mTableView.closing){
        [mTableView performClose:nil];
        return NSNotFound;
    }
    
    NSString *key = [contactsDictionaryAllKeys objectAtIndex:index];

    if (key == UITableViewIndexSearch) {
        [mTableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    
    return index;
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return contactsDictionaryAllKeys;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{    
    return contactsDictionaryAllKeys.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
     return contactsDictionaryAllKeys[section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ((NSArray*)contactsDictionary[contactsDictionaryAllKeys[section]]).count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"TransWait";
    ViewControllerCell *cell = [mTableView dequeueReusableCellWithIdentifier:identifier];
    if(!cell){
        cell = [[ViewControllerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.person = contactsDictionary[contactsDictionaryAllKeys[indexPath.section]][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    person =  contactsDictionary[contactsDictionaryAllKeys[indexPath.section]][indexPath.row];
    
    if(mTableView.subClassContentView != nil){
        return;
    }

    NSMutableArray *buttonDataArray = [[NSMutableArray alloc]initWithCapacity:0];
    //拨号
    NSDictionary *callDic =  [NSDictionary dictionaryWithObjectsAndKeys:@"电话", @"title", @"images/personfa_icon1@2x.png", @"image", nil];
    //短信
    NSDictionary *messDic =  [NSDictionary dictionaryWithObjectsAndKeys:@"短信", @"title", @"images/personfa_icon3@2x.png", @"image", nil];
    //查看
    NSDictionary *readlDic =  [NSDictionary dictionaryWithObjectsAndKeys:@"一键拨号", @"title", @"images/personfa_icon2@2x.png", @"image", nil];

    [buttonDataArray addObject:callDic];
    [buttonDataArray addObject:messDic];
    [buttonDataArray addObject:readlDic];
    
    SubCateViewController *subVc = [[[SubCateViewController alloc]
                                     init] autorelease];

    subVc.subCates = buttonDataArray;
    subVc.cateVC = self;
    
    [buttonDataArray release];

    __block UIFolderTableView *tv = mTableView;
    [mTableView openFolderAtIndexPath:indexPath WithContentView:subVc.view
                            openBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction) {
                                tv.scrollEnabled = FALSE;
                            } closeBlock:^(UIView *subClassView, CFTimeInterval duration, CAMediaTimingFunction *timingFunction) {
                                tv.scrollEnabled = TRUE;
                            } completionBlock:^{
                               
                            }];
}


-(void)touchUpInsideAction:(UIButton *)button{

    switch(button.tag){
        case 0:{
            [self createActionSheet:0];
            break;
        }
        case 1:{
            [self createActionSheet:1];
            break;
        }
        case 2:{
            ContactsDetailController *cdc = [[ContactsDetailController alloc]init];
            cdc.person = person;
            [self.navigationController pushViewController:cdc animated:YES];
            if(!mTableView.closing){
                [mTableView performClose:nil];
            }
        }
            break;
    }
    
}

-(void)createActionSheet:(int)tag{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"title" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    actionSheet.tag = tag;
    
    ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
    if ((phone != nil)&&ABMultiValueGetCount(phone)==1) {
        NSString *mobile = [(NSString *)ABMultiValueCopyValueAtIndex(phone, 0) autorelease];

        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@",(actionSheet.tag?@"sms":@"telprompt"),mobile]]];
        [webView loadRequest:request];
        
        
        NSLog(@"1--%d",[[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",mobile ]]]);
        NSLog(@"2--%d",[[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",mobile ]]]);
    }else if ((phone != nil)&&ABMultiValueGetCount(phone)>0) {
        for (int m = 0; m < ABMultiValueGetCount(phone); m++) {
            NSString *mobile = [(NSString *)ABMultiValueCopyValueAtIndex(phone, m) autorelease];
            //            NSString * aLabel = [(NSString *)ABMultiValueCopyLabelAtIndex(phone, m) autorelease];
            
            [actionSheet addButtonWithTitle:mobile];
            
        }
        
        [actionSheet addButtonWithTitle:@"取消"];
        actionSheet.cancelButtonIndex = ABMultiValueGetCount(phone);
        
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *num = [[NSString alloc] initWithFormat:@"%@://%@",(actionSheet.tag?@"sms":@"telprompt"),[actionSheet buttonTitleAtIndex:buttonIndex]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
