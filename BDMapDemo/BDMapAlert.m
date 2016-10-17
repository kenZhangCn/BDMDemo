//
//  BDMapAlert.m
//  BDMapDemo
//
//  Created by k&r on 2016/10/17.
//  Copyright © 2016年 k&r. All rights reserved.
//

#import "BDMapAlert.h"

@implementation BDMapAlert

/**弹出提示 雷达检测到用户*/
+ (UIAlertController *)showRaderAlert:(BMKRadarNearbyInfo *)nearbyInfo totalNum:(NSInteger)num{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"检测到%ld个用户 用户名:%@ 距离:%lu", num, nearbyInfo.userId, (unsigned long)nearbyInfo.distance] style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    return alert;
}
/**弹出提示 雷达检测到用户*/
+ (UIAlertController *)showRaderTotalNum:(NSInteger)num{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Rader检测到%ld个用户", num] style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    return alert;
}

/**弹出提示 总路程/总时间/平均速度*/
+ (UIAlertController *)showTotalDistance:(NSString *)distance totalTime:(NSString *)time averageSpeed:(NSString *)speed {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"行程" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"总路程为%@m 总时间为%@s 平均速度为%@m/s", distance, time, speed] style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    return alert;
}

/**弹出越境提醒*/
+ (UIAlertController *)showAlert:(NSString *)content {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@", content] style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    return alert;
}


@end
