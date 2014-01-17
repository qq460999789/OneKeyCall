//
//  SubCateViewController.m
//  top100
//
//  Created by Dai Cloud on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SubCateViewController.h"
#define COLUMN 4
#define ROWHEIHT 50  
#define RIGHTEDGE 20

@interface SubCateViewController ()

@end

@implementation SubCateViewController

@synthesize subCates=_subCates;
@synthesize cateVC=_cateVC;

- (void)dealloc
{
    [_subCates release];
    [_cateVC release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"images/personfa_gjbg@2x"] stretchableImageWithLeftCapWidth:6 topCapHeight:6]];
    
    // init cates show
    int total = self.subCates.count;//选项个数
  
    int rows = (total / COLUMN) + ((total % COLUMN) > 0 ? 1 : 0);//确定有几行
//        CGFloat leftEdge = 10.0f;   //预留边界宽度
        CGFloat leftEdge = 0.0f;   //预留边界宽度
    leftEdge = total == 4? 0:(total == 3? 37.5:(total == 2? 75 :112.5));
//    WMLOG(@"leftedge:%f",leftEdge);
        CGFloat buttonspace = 0.0f;
        int n = 0;
    for (int i = 0; i < total; i++) {
        int row = i / COLUMN;       //确定所在行
        int column = i % COLUMN;    //确定所在列
        NSDictionary *data = [self.subCates objectAtIndex:i];   //从数组中取出数据（字典）
        
        UIImage* buttonImage = [UIImage imageNamed:[data objectForKey:@"image"]];
//        CGFloat width = 48.0f;
//        CGFloat height  = width * buttonImage.size.height / buttonImage.size.width;
        CGFloat width = buttonImage.size.width/2.0;//控制图片大小
        CGFloat height  = buttonImage.size.height/2.0;
        int count = self.subCates.count > COLUMN ? COLUMN : self.subCates.count; //取一行的较小值
        if(n == 0){
            buttonspace = (CGFloat)(self.view.bounds.size.width-RIGHTEDGE-2*leftEdge-(count * 90))/(count + 1);
            //75是view的宽度
            n++;
            leftEdge = leftEdge + buttonspace;
        }
        
        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(leftEdge + 90*column, ROWHEIHT*row, 90, ROWHEIHT)] autorelease];
//        WMLOG(@"view---frame1:%@,leftedge:%f",NSStringFromCGRect(view.frame),leftEdge);

        view.backgroundColor = [UIColor clearColor];//换成clear

        //添加背景响应
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect viewFrame = view.frame;//69 43
        viewFrame.origin.x =  5;
        viewFrame.origin.y =  5;
        viewFrame.size.width = 80;
        viewFrame.size.height = 40;
        backBtn.frame = viewFrame;
//        WMLOG(@"-----backBtn:%@",NSStringFromCGRect(viewFrame));
        [backBtn setImage:[UIImage imageNamed:@"images/personfa_gjbg_p@2x.png"] forState:UIControlStateHighlighted];
        NSString *title = [data objectForKey:@"title"];


            backBtn.tag = i;

        
        [backBtn addTarget:self.cateVC
                action:@selector(touchUpInsideAction:)
      forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:backBtn];
        
        CGFloat fromY =(view.frame.size.height-height)/2.0;
        
        UIImageView *iconImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        iconImageView.frame = CGRectMake(15, fromY, width, height);
        iconImageView.image = [UIImage imageNamed:[data objectForKey:@"image"]];
        
//        leftEdge = leftEdge + width + buttonspace;
        if(i%COLUMN == COLUMN - 1){//列到头
            leftEdge = leftEdge + buttonspace;
        }
        [view addSubview:iconImageView];
        
        //添加文字标题
        UILabel *lbl = [[[UILabel alloc] initWithFrame:CGRectMake(0, 65, 80, 14)] autorelease];
        lbl.frame = CGRectMake(iconImageView.frame.origin.x+iconImageView.frame.size.width, 10, 50, 30);
        lbl.textAlignment = UITextAlignmentCenter;
        lbl.textColor = [UIColor colorWithRed:204/255.0 
                                        green:204/255.0 
                                         blue:204/255.0 
                                        alpha:1.0];
        lbl.textColor = [UIColor blackColor];
        lbl.font = [UIFont systemFontOfSize:12.0f];
        lbl.backgroundColor = [UIColor clearColor];
        lbl.text = title;
        [view addSubview:lbl];
        //添加分割线
        if(i < count-1){
        UIImageView *lineImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        CGRect frame = view.frame;
        frame.origin.x = frame.size.width -2;
        frame.origin.y = (ROWHEIHT - 79/2.0)/2.0;
        frame.size.width = 1.5;
        frame.size.height = 79/2.0f;
        lineImageView.frame = frame;
//            WMLOG(@"---frame:%@",NSStringFromCGRect(lineImageView.frame));
        lineImageView.image = [UIImage imageNamed:@"images/personfa_line_fg@2x.png"];
        [view addSubview:lineImageView];
        }
        [self.view addSubview:view];
//        WMLOG(@"view---frame1:%@",NSStringFromCGRect(view.frame));

    }
    
    CGRect viewFrame = self.view.frame;
//    WMLOG(@"frame:%@",NSStringFromCGRect(viewFrame));
    viewFrame.size.height = ROWHEIHT * rows;
    self.view.frame = viewFrame;
//    WMLOG(@"frame:%@",NSStringFromCGRect(viewFrame));

}

//-(void)subCateBtnAction:(UIButton *)sender{
//
//    if([self.delegate respondsToSelector:@selector(touchUpInsideAction:)]){
//        
//        [self.delegate performSelector:@selector(touchUpInsideAction:) withObject:sender];
//    
//    }
//
//
//
//}
@end
