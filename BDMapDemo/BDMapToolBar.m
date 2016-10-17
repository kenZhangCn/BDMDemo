//
//  BDMapToolBar.m
//  BDMapDemo
//
//  Created by k&r on 2016/10/17.
//  Copyright © 2016年 k&r. All rights reserved.
//

#import "BDMapToolBar.h"

@implementation BDMapToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:242/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
        //currentSpeed
        UILabel *currentSpeedLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH - 120, 0, 100, 44)];
        currentSpeedLabel.text = @" ";
        currentSpeedLabel.textAlignment = NSTextAlignmentRight;
        currentSpeedLabel.textColor = [UIColor whiteColor];
        [self addSubview:currentSpeedLabel];
        _currentSpeedLabel = currentSpeedLabel;
        //定位按钮
        UIButton *locationServiceButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 54, 44)];
        [locationServiceButton setTitle:@"开始" forState:UIControlStateNormal];
        [locationServiceButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        locationServiceButton.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:17.0];
        locationServiceButton.titleLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightLight];
        [self addSubview:locationServiceButton];
        [locationServiceButton addTarget:self action:@selector(startAndStopButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _locationServiceButton = locationServiceButton;
        //交通方式图标
        UIImage *walk = [UIImage imageNamed:@"walk"];
        UIImage *run = [UIImage imageNamed:@"run"];
        UIImage *bike = [UIImage imageNamed:@"bike"];
        UIImage *car = [UIImage imageNamed:@"car"];
        UIImageView *tranTypeView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, walk.size.width, walk.size.height)];
        tranTypeView.center = CGPointMake(WIDTH * 0.5, 22);
        tranTypeView.image = walk;
        [self addSubview:tranTypeView];
        _tranTypeView = tranTypeView;

    }
    return self;
}

- (void)startAndStopButtonClick {
    [self.delegate startAndStopButtonDidClick:self];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
