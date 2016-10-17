//
//  BDMapViewController.m
//  BDMapDemo
//
//  Created by k&r on 2016/10/15.
//  Copyright © 2016年 k&r. All rights reserved.
//

#import "BDMapViewController.h"

@interface BDMapViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKRadarManagerDelegate, BDMapToolBarDelegate>

//地图图层
@property (strong, nonatomic) BMKMapView *mapView;
//定位图层
@property (strong, nonatomic) BMKLocationService *locationService;
//检索对象
@property (strong, nonatomic) BMKGeoCodeSearch *geoCodeSearcher;
//数据表
@property (strong, nonatomic) FMDatabase *db;
//周边雷达
@property (strong, nonatomic) BMKRadarManager *radarManager;
//运动管理
@property (strong, nonatomic) CMMotionManager *motionManager;
//当前速度
@property (weak, nonatomic) UILabel *currentSpeedLabel;
//定位按钮
@property (weak, nonatomic) UIButton *locationServiceButton;
//交通方式
@property (weak, nonatomic) UIImageView *tranTypeView;
//start
@property (assign, nonatomic) BOOL isStart;
//setStartPoint
@property (assign, nonatomic) BOOL isStartPoint;
//离开深圳提醒
@property (assign, nonatomic) BOOL isShowAlert;
//开始按钮状态
@property (assign, nonatomic) BOOL buttonState;
//运动计数
@property (nonatomic, assign) int motionCount;
//运动计时
@property (strong, nonatomic) NSTimer *motionTimer;
//折线图起点
@property (assign, nonatomic) float startPointLatitude;
@property (assign, nonatomic) float startPointLongitude;



@end

@implementation BDMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BMKMapDemo";
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    _isStart = NO;
    _isStartPoint = NO;
    _isShowAlert = YES;
    _buttonState = YES;
    [self setNavStyle];
    
    //初始化DataBase
    [self initDataBase];

    //初始化基础地图服务
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_mapView];
    _mapView.mapType = BMKMapTypeStandard;
    _mapView.showMapScaleBar = YES;
    _mapView.showsUserLocation = YES;
    _motionCount = 0;
    
    //初始化检索对象
    _geoCodeSearcher = [[BMKGeoCodeSearch alloc] init];
    
    //初始化雷达对象
    _radarManager = [BMKRadarManager getRadarManagerInstance];
//    [_radarManager setUserId:@"ken"];
    
    //初始化操作界面
    [self initView];
    
    //初始化BMKLocationService位置服务
    _locationService = [[BMKLocationService alloc] init];
    _locationService.desiredAccuracy = kCLLocationAccuracyBest;
    _locationService.delegate = self;
    _locationService.pausesLocationUpdatesAutomatically = NO;
    if([[[UIDevice currentDevice] systemVersion] floatValue]>9.0){
        [_locationService setAllowsBackgroundLocationUpdates:YES];
    }
//    [self moveToCurrentLocation];
    
}

- (void)setNavStyle {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:242/255.0 green:60/255.0 blue:60/255.0 alpha:1.0];
    NSDictionary *textDict = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size:16.0], NSFontAttributeName: [UIFont systemFontOfSize:16.0 weight:UIFontWeightLight]};
    [self.navigationController.navigationBar setTitleTextAttributes:textDict];
    //不半透明
    self.navigationController.navigationBar.translucent = NO;
    //隐藏黑线
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}
-(CMMotionManager *)motionManger{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc]init];
        _motionManager.accelerometerUpdateInterval = 1.0;
    }
    return _motionManager;
}
/**初始化DataBase*/
- (void)initDataBase {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"location.sqlite"];
    _db = [FMDatabase databaseWithPath:filePath];
    [_db open];
    
    [_db executeUpdate:@"DROP TABLE IF EXISTS 'location' "];    //删除表
    [_db executeUpdate:@"DROP TABLE IF EXISTS 'locationForTenSecond' "];    //删除表

    // 初始化数据表
    NSString *locationSql = @"CREATE TABLE 'location' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'location_id' VARCHAR(255), 'location_latitude' VARCHAR(255),'location_longitude' VARCHAR(255),'location_distance' VARCHAR(255),'location_speed' VARCHAR(255),'location_acceleration' VARCHAR(255))";
    NSString *locationSqlForTenSecond = @"CREATE TABLE 'locationForTenSecond' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL , 'location_id' VARCHAR(255), 'location_latitude' VARCHAR(255),'location_longitude' VARCHAR(255),'location_speed' VARCHAR(255))";
    [_db executeUpdate:locationSql];
    [_db executeUpdate:locationSqlForTenSecond];
    
    [_db close];
//    NSLog(@"%@",filePath);
}
- (void)initView {
    BDMapToolBar *toolBar = [[BDMapToolBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, 44)];
    [self.view addSubview:toolBar];
    toolBar.delegate = self;
    _currentSpeedLabel = toolBar.currentSpeedLabel;
    _locationServiceButton = toolBar.locationServiceButton;
    _tranTypeView = toolBar.tranTypeView;
    //实时路况按钮
    UIButton *tranStateButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 54, HEIGHT - 190, 44, 44)];
    [tranStateButton setImage:[UIImage imageNamed:@"road"] forState:UIControlStateNormal];
    [self.view addSubview:tranStateButton];
    [tranStateButton addTarget:self action:@selector(tranStateButtonClick) forControlEvents:UIControlEventTouchUpInside];
    //热力图按钮
    UIButton *radarButton = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH - 54, HEIGHT - 135, 44, 44)];
    [radarButton setImage:[UIImage imageNamed:@"radar"] forState:UIControlStateNormal];
    [radarButton addTarget:self action:@selector(radarButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:radarButton];
}
- (void)startAndStopButtonDidClick:(BDMapToolBar *)toolBar {
    [self startAndStopButtonClick];
}

- (void)moveToCurrentLocation {
    [_locationService startUserLocationService];
    _mapView.showsUserLocation = YES;  //显示定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;  //设置定位的状态
    [NSTimer timerWithTimeInterval:1.0 target:_locationService selector:@selector(stopUserLocationService) userInfo:nil repeats:NO];
}

- (void)startAndStopButtonClick {
    if (_buttonState) {
        [self startLocationService];
        [_locationServiceButton setTitle:@"停止" forState:UIControlStateNormal];
        _buttonState = NO;
    } else {
        [self stopLocationService];
        [_locationServiceButton setTitle:@"开始" forState:UIControlStateNormal];
        _buttonState = YES;
    }
}
/**打开实时路况图层*/
- (void)tranStateButtonClick {
    BOOL traffic = _mapView.trafficEnabled;
    [_mapView setTrafficEnabled:!traffic];
}
/**打开百度城市热力图图层（百度自有数据)*/
- (void)radarButtonClick {
    BOOL heatMap = _mapView.baiduHeatMapEnabled;
    [_mapView setBaiduHeatMapEnabled:!heatMap];
}

/**启动LocationService和加速计*/
- (void)startLocationService {
    [_locationService startUserLocationService];
    _mapView.zoomLevel = 18;
    _mapView.showsUserLocation = YES;  //显示定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;  //设置定位的状态
    NSLog(@"开始定位!");
    if (_motionManager.accelerometerAvailable) {  //加速计可用
        _motionManager.accelerometerUpdateInterval = 1.0;
        [_motionManager startAccelerometerUpdates];
        NSLog(@"开始更新加速计数据!");
    } else {
        NSLog(@"加速计不可用!");
    }
    _motionTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        _motionCount = 0;
        NSLog(@"计数归0");
    }];
}
/**停止定位并展示 总路程/总时间/平均速度*/
- (void)stopLocationService {
    [_locationService stopUserLocationService];
    if (_motionManager.accelerometerAvailable) {  //加速计可用
        [_motionManager stopAccelerometerUpdates];
    }
    if (_motionTimer) {
        [_motionTimer invalidate];
        _motionTimer = nil;
    }
    _currentSpeedLabel.text = @"0 m/s";
    float totalDistance = 0.0;
    int totalTime = 0;
    
    [_db open];
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM location"];
    while ([res next]) {
        float dis = [[res stringForColumn:@"location_speed"] floatValue];
        totalDistance += dis;
        float time = [[res stringForColumn:@"location_id"] integerValue];
        totalTime = time;
    }
    [_db close];
        
    float averageSpeed = totalDistance / totalTime;
    NSString *totalD = [NSString stringWithFormat:@"%.0f", totalDistance];
    NSString *totalT = [NSString stringWithFormat:@"%d", totalTime];
    NSString *averageS = [NSString stringWithFormat:@"%.1f", averageSpeed];
    //弹出提示
    [self presentViewController:[BDMapAlert showTotalDistance:totalD totalTime:totalT averageSpeed:averageS] animated:YES completion:nil];
}
    
/**插入数据并更新界面*/
- (void)addLocation:(BMKUserLocation *)userLocation {
    float latitude = userLocation.location.coordinate.latitude;
    float longitude = userLocation.location.coordinate.longitude;
    float speed = userLocation.location.speed;
    //判别运动类别
    [self judgeSportStateWithAccelerationAndSpeed:speed];
    if (speed == -1) {
        speed = 0;
    }
    
    [_db open];
//    [_db executeUpdate:@"DELETE FROM 'location' "];  //删除表数据
    NSNumber *maxID = @0;
    float lastLatitude = 0;
    float lastLongitude = 0;
    float lastSpeed = 0;
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM location"];
    //获取数据库中最大的ID
    while ([res next]) {
        if ([maxID integerValue] < [[res stringForColumn:@"location_id"] integerValue]) {
            maxID = @([[res stringForColumn:@"location_id"] integerValue] ) ;
            //获取上一个数据
            lastLatitude = [[res stringForColumn:@"location_latitude"] floatValue];
            lastLongitude = [[res stringForColumn:@"location_longitude"] floatValue];
            lastSpeed = [[res stringForColumn:@"location_speed"] floatValue];
        }
    }
    maxID = @([maxID integerValue] + 1);
    if ([maxID integerValue] == 1) {
        [_mapView updateLocationData:userLocation];  //显示到地图图层
    }
    //计算距离并显示实时速度(1s更新一次)
    CLLocationDistance distance = 0;
    float acceleration = 0.0;
    if (lastLongitude != 0 || lastLatitude != 0) {
        distance = [self calcutDistanceFromPointOneLatitude:lastLatitude longitude:lastLongitude toPointTwoLatitude:latitude longitude:longitude];
        acceleration = speed - lastSpeed;
        _currentSpeedLabel.text = [NSString stringWithFormat:@"%.1f m/s", speed];
    }
    //储存每秒数据
    [_db executeUpdate:@"INSERT INTO location(location_id,location_latitude,location_longitude,location_distance,location_speed,location_acceleration)VALUES(?,?,?,?,?,?)",maxID,@(latitude),@(longitude),@(distance),@(speed),@(acceleration)];
    //剔除不规律坐标
    if (!_isStartPoint) {
        if (distance != 0) {
            _startPointLatitude = latitude;
            _startPointLongitude = longitude;
            _isStartPoint = YES;
        }
    }
    //10s一次记录位置
    int id = [maxID integerValue] % 10;
    if (id == 1) {
        [_db executeUpdate:@"INSERT INTO locationForTenSecond(location_id,location_latitude,location_longitude)VALUES(?,?,?)",maxID,@(latitude),@(longitude)];
        [_mapView updateLocationData:userLocation];  //显示到地图图层
        if (_startPointLatitude || _startPointLongitude) {
            float endPointLatitude = latitude;
            float endPointLongitude = longitude;
            [self drawPolylineFromPointOneLatitude:_startPointLatitude longitude:_startPointLongitude toPointTwoLatitude:endPointLatitude longitude:endPointLongitude];
            _startPointLatitude = latitude;
            _startPointLongitude = longitude;
            //上传位置信息到雷达模块(10s一次)
            [self radarUploadLocation:userLocation.location.coordinate];
            //利用雷达检索周边
            [self radarNearbySearch:userLocation.location.coordinate];
        }
    }
    
    [_db close];
}

/**绘制折线*/
- (void)drawPolylineFromPointOneLatitude:(float)lat1 longitude:(float)lon1 toPointTwoLatitude:(float)lat2 longitude:(float)lon2 {
    CLLocationCoordinate2D coords[2] = {0};
    coords[0].latitude = lat1;
    coords[0].longitude = lon1;
    coords[1].latitude = lat2;
    coords[1].longitude = lon2;
    BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:coords count:2];
    [_mapView addOverlay:polyline];
}
/**折线绘制方法*/
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]){
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    return nil;
}
/**计算两点距离(经纬度)*/
- (CLLocationDistance)calcutDistanceFromPointOneLatitude:(float)lat1 longitude:(float)lon1 toPointTwoLatitude:(float)lat2 longitude:(float)lon2 {
    BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(lat1,lon1));
    BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(lat2,lon2));
    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
    return distance;
}

#pragma mark - 定位代理方法
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    NSLog(@"heading is %@",userLocation.heading);
    [_mapView updateLocationData:userLocation];

}
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    NSLog(@"didUpdateUserLocation latitude=%f,longitude=%f speed=%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude, userLocation.location.speed);
    //储存位置数据
    [self addLocation:userLocation];
    //反编码城市
    [self applyReverseGeoCodeSearch:userLocation.location.coordinate];
    //得到规律定位数据后显示到地图图层
    if (!_isStart) {
        if ([self isLocationRegularity]) {
            [_mapView updateLocationData:userLocation];
            _isStart = YES;
        }
    }
}

/**上传位置信息*/
- (void)radarUploadLocation:(CLLocationCoordinate2D)coord {
    //构造我的位置信息
    BMKRadarUploadInfo *myinfo = [[BMKRadarUploadInfo alloc] init];
    myinfo.extInfo = @"location";//扩展信息
    myinfo.pt = coord;//我的地理坐标
    //上传我的位置信息
    BOOL res = [_radarManager uploadInfoRequest:myinfo];
    if (res) {
        NSLog(@"upload 成功");
    } else {
        NSLog(@"upload 失败");
    }
}
/**上传位置结果回调*/
- (void)onGetRadarUploadResult:(BMKRadarErrorCode)error {
    if (error == BMK_RADAR_NO_ERROR) {
        NSLog(@"成功上传位置!");
    }
}
/**利用雷达检索周边*/
- (void)radarNearbySearch:(CLLocationCoordinate2D)coord  {
    BMKRadarNearbySearchOption *option = [[BMKRadarNearbySearchOption alloc] init]
    ;
    option.radius = 20;//检索半径
    option.sortType = BMK_RADAR_SORT_TYPE_DISTANCE_FROM_NEAR_TO_FAR;//排序方式
    option.centerPt = coord;//检索中心点
    //发起检索
    BOOL res = [_radarManager getRadarNearbySearchRequest:option];
    if (res) {
        NSLog(@"雷达检索 成功");
    } else {
        NSLog(@"雷达检索 失败");
    }
}
/**雷达检索回调*/
- (void)onGetRadarNearbySearchResult:(BMKRadarNearbyResult *)result error:(BMKRadarErrorCode)error {
    NSLog(@"onGetRadarNearbySearchResult  %d", error);
    if (error == BMK_RADAR_NO_ERROR) {  //返回数据成功
        NSInteger totalNum = result.totalNum;  //总结果数
        for (int i = 0; i < totalNum; i ++) {
            BMKRadarNearbyInfo *nearbyInfo = result.infoList[i];
            ///用户id
            NSString *userId = nearbyInfo.userId;
            ///地址坐标
            CLLocationCoordinate2D pt = nearbyInfo.pt;
            ///距离
            NSUInteger distance = nearbyInfo.distance;
            ///扩展信息
            NSString* extInfo = nearbyInfo.extInfo;
            ///设备类型
            NSString* mobileType = nearbyInfo.mobileType;
            ///设备系统
            NSString* osType = nearbyInfo.osType;
            ///时间戳
            NSTimeInterval timeStamp = nearbyInfo.timeStamp;
            NSLog(@"检测到%ld个用户 用户名:%@ 距离:%lu 时间:%f", (long)totalNum, userId, (unsigned long)distance, timeStamp);
        }
        //弹出提示检测到用户
        [self presentViewController:[BDMapAlert showRaderTotalNum:totalNum] animated:YES completion:nil];
    }
}

/**是否获得稳定规律定位数据*/
- (BOOL)isLocationRegularity {
    float distance = 0.0;
    BOOL isLocationMove = YES;
    [_db open];
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM location"];
    //获取数据库中最大的ID
    while ([res next]) {
        distance = [[res stringForColumn:@"location_distance"] integerValue] ;
    }
    if (distance == 0) {
        isLocationMove = NO;
    } else {
        isLocationMove = YES;
    }
    [_db close];
    return isLocationMove;
}

/**发起反向地理编码检索*/
- (void)applyReverseGeoCodeSearch:(CLLocationCoordinate2D)coord {
    CLLocationCoordinate2D pt = coord;
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geoCodeSearcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag) {
      NSLog(@"反geo检索发送成功");
    } else {
      NSLog(@"反geo检索发送失败");
    }
}
/**反向编码回调*/
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == 0) {  //检索结果正常返回
        BMKAddressComponent *addressDetail = result.addressDetail;
        NSString *address = result.address;
        CLLocationCoordinate2D location = result.location;
        NSArray *poiList = result.poiList;
        NSString *city = addressDetail.city;
        if (_isShowAlert) {  //提醒一次
            if (![city isEqualToString:@"深圳市"]) {
                //弹出提示
                [self presentViewController:[BDMapAlert showAlert:@"您已离开深圳市!"] animated:YES completion:nil];
                _isShowAlert = NO;
            }
        }
        NSLog(@"省份:%@ 城市:%@ 地址:%@", addressDetail.province, addressDetail.city, address);
    }
}

/**以加速度和速度判别运动状态*/
- (void)judgeSportStateWithAccelerationAndSpeed:(float)speed {
    UIImage *walk = [UIImage imageNamed:@"walk"];
    UIImage *run = [UIImage imageNamed:@"run"];
    UIImage *bike = [UIImage imageNamed:@"bike"];
    UIImage *car = [UIImage imageNamed:@"car"];
    
    CMAcceleration acceleration = self.motionManager.accelerometerData.acceleration;
    CGFloat y = acceleration.y;
    CGFloat z = acceleration.z;
    CGFloat x = acceleration.x;
    //speed
    if (speed > 14) {  //速度>14m/s -> 驾车
        _tranTypeView.image = car;
        _tranTypeView.frame = CGRectMake(0, 0, car.size.width, car.size.height);
    } else if (speed <= 14 || speed > 4) {  //驾车 骑车
        NSLog(@"驾车 骑车");
    } else if (speed <= 4 || speed > 2.2) { //驾车 骑车 跑步
        NSLog(@"驾车,骑车或跑步");
    } else { //驾车 骑车 跑步 走路
        NSLog(@"驾车,骑车,跑步或走路");
        _tranTypeView.image = walk;
        _tranTypeView.frame = CGRectMake(0, 0, walk.size.width, walk.size.height);
    }
    //acceleration
    if (fabs(x)>3 || fabs(y)>3 || fabs(z)>3) {  //5min超过5次加速度>3m/s2 -> 驾车
        _motionCount ++;
        if (_motionCount > 5) {
            _tranTypeView.image = car;
            _tranTypeView.frame = CGRectMake(0, 0, car.size.width, car.size.height);
        }
    } else {
        NSLog(@"骑车,跑步或走路");
    }
    _tranTypeView.center = CGPointMake(WIDTH * 0.5, 22);
}

- (void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geoCodeSearcher.delegate = self;
    [_radarManager addRadarManagerDelegate:self];
}
- (void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _geoCodeSearcher.delegate = nil;
    [_radarManager removeRadarManagerDelegate:self];
}
- (void)dealloc {
    if (_geoCodeSearcher != nil) {
        _geoCodeSearcher = nil;
    }
    if (_mapView) {
        _mapView = nil;
    }
    _radarManager = nil;
    [BMKRadarManager releaseRadarManagerInstance];
    [_motionTimer invalidate];
    _motionTimer = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* 坐标转换
- (void)coordinateConvert {
     CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(1.0, 0);//原始坐标
     //转换 google地图、soso地图、aliyun地图、mapabc地图和amap地图所用坐标至百度坐标
     NSDictionary* testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_COMMON);
     //转换GPS坐标至百度坐标(加密后的坐标)
     testdic = BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
     NSLog(@"x=%@,y=%@",[testdic objectForKey:@"x"],[testdic objectForKey:@"y"]);
     //解密加密后的坐标字典
     CLLocationCoordinate2D baiduCoor = BMKCoorDictionaryDecode(testdic);//转换后的百度坐标
     NSLog(@"%f %f", baiduCoor.latitude, baiduCoor.longitude);
     CLLocationDistance baiduDis = [self calcutDistanceFromPointOneLatitude:baiduCoor.latitude longitude:baiduCoor.longitude toPointTwoLatitude:0 longitude:0];
     NSLog(@"%f米  %f米", dis, baiduDis);
     CLLocationDistance dis = [self calcutDistanceFromPointOneLatitude:20.0 longitude:0 toPointTwoLatitude:19.0 longitude:0];
     NSLog(@"%f米", dis);
}
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
