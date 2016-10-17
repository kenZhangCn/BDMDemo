//
//  BDMapToolBar.h
//  BDMapDemo
//
//  Created by k&r on 2016/10/17.
//  Copyright © 2016年 k&r. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Configuration.h"

@class BDMapToolBar;

@protocol BDMapToolBarDelegate <NSObject>

- (void)startAndStopButtonDidClick:(BDMapToolBar *)toolBar;

@end


@interface BDMapToolBar : UIView

//当前速度
@property (weak, nonatomic) UILabel *currentSpeedLabel;
//定位按钮
@property (weak, nonatomic) UIButton *locationServiceButton;
//交通方式
@property (weak, nonatomic) UIImageView *tranTypeView;
@property (weak, nonatomic) id<BDMapToolBarDelegate> delegate;


@end
