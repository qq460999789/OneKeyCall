//
//  UIFolderTableView.m
//  top100
//
//  Created by Dai Cloud on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIFolderTableView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+screenshot.h"

#define COVERALPHA 0.6

@interface UIFolderTableView ()

@property (nonatomic, strong) FolderCoverView *top, *bottom;
@property (nonatomic) CGPoint oldTopPoint, oldBottomPoint;
@property (nonatomic) CGPoint oldContentOffset;

@property (nonatomic) CGFloat offsetY;
@property (nonatomic, copy) FolderOpenBlock openBlock;
@property (nonatomic, copy) FolderCloseBlock closeBlock;
@property (nonatomic, copy) FolderCompletionBlock completionBlock;

@end

@implementation UIFolderTableView

@synthesize top=_top, bottom=_bottom;
@synthesize oldTopPoint=_oldTopPoint, oldBottomPoint=_oldBottomPoint;
@synthesize closing=_closing;
@synthesize subClassContentView=_subClassContentView;
@synthesize openBlock=_openBlock, closeBlock=_closeBlock, completionBlock=_completionBlock;
@synthesize offsetY=_offsetY;
@synthesize oldContentOffset=_oldContentOffset;
@synthesize folderDelegate=_folderDelegate;

- (void)dealloc
{
    [_top release];
    [_bottom release];
    [_subClassContentView release];
    [super dealloc];
}



- (void)openFolderAtIndexPath:(NSIndexPath *)indexPath
                      WithContentView:(UIView *)subClassContentView
                        openBlock:(FolderOpenBlock)openBlock 
                       closeBlock:(FolderCloseBlock)closeBlock
                  completionBlock:(FolderCompletionBlock)completionBlock
{
    // 
    self.subClassContentView = subClassContentView;
    self.openBlock = openBlock;
    self.closeBlock = closeBlock;
    self.completionBlock = completionBlock;
    self.closing = NO;
    
    // 位置和高度参数
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];//获得选中的cell
    NSLog(@"cellFrame:%@",NSStringFromCGRect(cell.frame));
    self.rowHeight = cell.frame.size.height;//cell的行高
    CGFloat deltaY = self.contentOffset.y;//tableview的偏移
    CGFloat positionX;

    // 小三角的位置x坐标
    if ([self.folderDelegate respondsToSelector:@selector(tableView:xForRowAtIndexPath:)]) {
        positionX = [self.folderDelegate tableView:self xForRowAtIndexPath:indexPath];
    } else {
        positionX = 40;
    }
    CGPoint position = CGPointMake(positionX, cell.frame.origin.y+cell.frame.size.height - 1);//添加view的起点
    
    CGFloat width = self.frame.size.width;  //tableview的width
    CGFloat height = self.frame.size.height;//tableview的height
    NSLog(@"frame%@",NSStringFromCGRect(self.frame));

    if (position.y - deltaY > height) {//得到开始添加view的页面可视高度 > tableview的高度时
        self.offsetY = position.y - height - deltaY;
    } else {
        self.offsetY = 0.0f;
    }
    
    // 重置contentoffset  这里要动画吗？
    self.oldContentOffset = self.contentOffset;
    self.contentOffset = CGPointMake(0, self.offsetY + deltaY);
    
    deltaY = self.contentOffset.y;

    UIImage *screenshot = [self screenshotWithOffset:-deltaY];
    
    // 配置上下遮罩
    CGRect upperRect = CGRectMake(0, deltaY, width, position.y - deltaY);
    CGRect lowerRect = CGRectMake(0, position.y, width, height + deltaY - position.y);

    
    self.top = [self buttonForRect:upperRect
                            screen:screenshot
                          position:position
                               top:YES
                       transparent:NO];
    self.bottom = [self buttonForRect:lowerRect
                               screen:screenshot
                             position:position
                                  top:NO
                          transparent:NO];
    // 绑定关闭动作
    [self.top addTarget:self action:@selector(performClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottom addTarget:self action:@selector(performClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.top.cover addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)] autorelease]];
    [self.bottom.cover addGestureRecognizer:[[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)] autorelease]];
    
    [self addSubview:subClassContentView];
    [self addSubview:self.top];
    [self addSubview:self.bottom];

    CGRect viewFrame = subClassContentView.frame;
    if (position.y - deltaY + viewFrame.size.height > height) {
        viewFrame.origin.y = height + deltaY - viewFrame.size.height;
    } else {
        viewFrame.origin.y = position.y;
    }
    subClassContentView.frame = viewFrame;

    // 配置打开动画
    CGFloat contentHeight = subClassContentView.frame.size.height;
    CFTimeInterval duration = 0.2f;
    CGPoint toTopPoint;
    CABasicAnimation *moveTop = [CABasicAnimation animationWithKeyPath:@"position"];
    moveTop.duration = duration;
    moveTop.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.oldTopPoint = self.top.layer.position;
    CGFloat newTopY;
    if (self.top.frame.origin.y + self.top.frame.size.height > subClassContentView.frame.origin.y) {
        newTopY = self.oldTopPoint.y + subClassContentView.frame.origin.y - (self.top.frame.origin.y + self.top.frame.size.height);
    } else {
        newTopY = self.oldTopPoint.y;
    }
    toTopPoint = (CGPoint){ self.oldTopPoint.x, newTopY};
    moveTop.fromValue = [NSValue valueWithCGPoint:self.oldTopPoint];
    moveTop.toValue = [NSValue valueWithCGPoint:toTopPoint];
    
    
    CGPoint toBottomPoint;
    CABasicAnimation *moveBottom = [CABasicAnimation animationWithKeyPath:@"position"];
    moveBottom.duration = duration;
    moveBottom.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.oldBottomPoint = self.bottom.layer.position;
    CGFloat newBottomY;
    if (subClassContentView.frame.origin.y + subClassContentView.frame.size.height > height + deltaY ) {
        newBottomY = self.oldBottomPoint.y + (subClassContentView.frame.origin.y + contentHeight) - deltaY - height;
    } else {
        newBottomY = self.oldBottomPoint.y + contentHeight;
    }
    toBottomPoint = (CGPoint){ self.oldBottomPoint.x, newBottomY};
    moveBottom.fromValue = [NSValue valueWithCGPoint:self.oldBottomPoint];
    moveBottom.toValue = [NSValue valueWithCGPoint:toBottomPoint];

    // 打开动画
    [self.top.layer addAnimation:moveTop forKey:@"t1"];
    [self.bottom.layer addAnimation:moveBottom forKey:@"t2"];

    // 透明变半透明
    [UIView animateWithDuration:duration animations:^{
        self.top.cover.alpha = COVERALPHA;
//        NSLog(@"self.top.frame:%@",NSStringFromCGRect(self.top.cover.frame));
        self.bottom.cover.alpha = COVERALPHA;
    }];

    if (openBlock) openBlock(self.subClassContentView, duration, [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]);
    
    [self.top.layer setPosition:toTopPoint];
    [self.bottom.layer setPosition:toBottomPoint];
    
}

-(void)tapGestureAction:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateChanged || 
        gesture.state == UIGestureRecognizerStateEnded) {
        if (gesture.numberOfTapsRequired > 0) {
            [self performClose:gesture];
        }
    }
}

- (void)performClose:(id)sender {
    if (self.closing) {
        return;
    }else {
        self.closing = YES;
    }
    
    // 配置关闭动画
    CFTimeInterval duration = 0.4f;//0.4f;
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *moveTop = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveTop setValue:@"close" forKey:@"animationType"];
    [moveTop setDelegate:self];
    [moveTop setTimingFunction:timingFunction];
    moveTop.fromValue = [NSValue valueWithCGPoint:[[self.top.layer presentationLayer] position]];
    moveTop.toValue = [NSValue valueWithCGPoint:self.oldTopPoint];
    moveTop.duration = duration;

    
    CABasicAnimation *moveBottom = [CABasicAnimation animationWithKeyPath:@"position"];
    [moveBottom setValue:@"close" forKey:@"animationType"];
    [moveBottom setDelegate:self];
    [moveBottom setTimingFunction:timingFunction];
    moveBottom.fromValue = [NSValue valueWithCGPoint:[[self.bottom.layer presentationLayer] position]];
    moveBottom.toValue = [NSValue valueWithCGPoint:self.oldBottomPoint];
    moveBottom.duration = duration;
    
    // 关闭动画 
    [self.top.layer addAnimation:moveTop forKey:@"b1"];
    [self.bottom.layer addAnimation:moveBottom forKey:@"b2"];
    
    // 半透明变透明
    [UIView animateWithDuration:duration animations:^{
        
        self.contentOffset = self.oldContentOffset;
        self.top.cover.alpha = 0;
        self.bottom.cover.alpha = 0;
//        NSArray *subbuttonArray =  self.subClassContentView.subviews;
//        for(UIView *view in subbuttonArray){
//        
//            view.alpha = 0;
//        }
//        self.subClassContentView.alpha = 0;
//        
//        CGRect subClassContentViewFrame = self.subClassContentView.frame;
//        subClassContentViewFrame.size.height = 0;
//        self.subClassContentView.frame = subClassContentViewFrame;
    }];
    
    if (self.closeBlock) self.closeBlock(self.subClassContentView, duration, timingFunction);
    
    [self.top.layer setPosition:self.oldTopPoint];
    [self.bottom.layer setPosition:self.oldBottomPoint];
}

-(void)performCloseNow:(id)sender {
    
    if (self.closing) {
        return;
    }else {
        self.closing = YES;
    }

// 半透明变透明
    self.contentOffset = self.oldContentOffset;
    self.top.cover.alpha = 0;
    self.bottom.cover.alpha = 0;

//    
//    [self.top.layer setPosition:self.oldTopPoint];
//    [self.bottom.layer setPosition:self.oldBottomPoint];

    [self.top removeFromSuperview];
    [self.bottom removeFromSuperview];
    [self.subClassContentView removeFromSuperview];
    
    self.top = nil;
    self.bottom = nil;
    self.subClassContentView = nil;
    
    if (self.completionBlock) self.completionBlock();
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    if ([[anim valueForKey:@"animationType"] isEqualToString:@"close"]) {        
        [self.top removeFromSuperview];
        [self.bottom removeFromSuperview];
        [self.subClassContentView removeFromSuperview];
        
        self.top = nil;
        self.bottom = nil;
        self.subClassContentView = nil;
        
        if (self.completionBlock) self.completionBlock();
//        sharedInstance = nil;
    }
    
}

- (FolderCoverView *)buttonForRect:(CGRect)aRect
                              screen:(UIImage *)screen
                            position:(CGPoint)position
                                 top:(BOOL)isTop
                         transparent:(BOOL)isTransparent {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat width = aRect.size.width;
    CGFloat height = aRect.size.height;
    CGPoint origin = aRect.origin;
    CGFloat deltaY = self.contentOffset.y;
    
    CGRect scaledRect = CGRectMake(origin.x*scale, origin.y*scale - deltaY*scale, width*scale, height*scale);
    CGImageRef ref1 = CGImageCreateWithImageInRect([screen CGImage], scaledRect);
    
    UIImage *contentsImage = [UIImage imageWithCGImage: ref1];
    CGImageRelease(ref1);
    
    
    FolderCoverView *button;
    if (isTop) {
        button = [[[FolderCoverView alloc] initWithFrame:aRect offset:self.rowHeight] autorelease];
        
        
        UIImageView *notch = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip.png"]] autorelease];
        notch.center = CGPointMake(position.x, height - 2);
        [button addSubview:notch];
        
    } else {
        button = [[[FolderCoverView alloc] initWithFrame:aRect offset:0] autorelease];
        
        
    }
    
    int offset = 100;
    CGRect scaledRect2 = CGRectMake(width*scale - offset , origin.y*scale - deltaY*scale, offset/2 , height*scale);
    CGImageRef ref2 = CGImageCreateWithImageInRect([screen CGImage], scaledRect2);
    
    UIGraphicsBeginImageContext(scaledRect.size);
    [contentsImage drawInRect:CGRectMake(0, 0, scaledRect.size.width  , scaledRect.size.height)];
    [[UIImage imageWithCGImage: ref2] drawInRect:CGRectMake(width*scale - offset/2, 0, offset/2  , scaledRect.size.height)];
    CGImageRelease(ref2);
    
    contentsImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [button setIsTopView:isTop];
    
    button.position = position;
    button.layer.contentsScale = scale;
    button.layer.contents = isTransparent ? nil : (id)(contentsImage.CGImage);
    button.layer.contentsGravity = kCAGravityCenter;

    
    return button;
}

@end
