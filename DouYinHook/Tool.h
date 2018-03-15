//
//  PhotoTool.h
//  AirBrush
//
//  Created by albus on 2017/10/16.
//  Copyright © 2017年 Hippo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlertSheetAction) (void);

@interface Tool : NSObject

//保存视频
+(void)saveToAlbumWithLocalVideoPath:(NSString*)locaoVideoPath andFinishHandler:(void (^) (BOOL isSuccessfull))theSuccess;

//弹出Sheet类型的弹出框
+ (void)popSheetAlertOnVC:(UIViewController*)vc withTitle:(NSString*)title andMessage:(NSString*)message andFuncNames:(NSArray*)funcNames andActions:(NSArray<AlertSheetAction>*)actions;

@end
