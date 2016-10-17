//
//  BDMapAlert.h
//  BDMapDemo
//
//  Created by k&r on 2016/10/17.
//  Copyright © 2016年 k&r. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Radar/BMKRadarComponent.h>//引入周边雷达功能所有的头文件


@interface BDMapAlert : NSObject

+ (UIAlertController *)showRaderAlert:(BMKRadarNearbyInfo *)nearbyInfo totalNum:(NSInteger)num;
+ (UIAlertController *)showRaderTotalNum:(NSInteger)num;
+ (UIAlertController *)showTotalDistance:(NSString *)distance totalTime:(NSString *)time averageSpeed:(NSString *)speed;
+ (UIAlertController *)showAlert:(NSString *)content;

@end
