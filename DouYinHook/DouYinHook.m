//  weibo: http://weibo.com/xiaoqing28
//  blog:  http://www.alonemonkey.com
//
//  DouYinHook.m
//  DouYinHook
//
//  Created by albus on 2018/3/15.
//  Copyright (c) 2018年 albus. All rights reserved.
//

#import "DouYinHook.h"
#import <CaptainHook/CaptainHook.h>
#import <UIKit/UIKit.h>
#import "DouYinAppInterface.h"
#import "Tool.h"

CHDeclareClass(AWEAwemeShareViewController)

CHOptimizedMethod1(self, void, AWEAwemeShareViewController, clicked, id, arg1)
{
    UIView *clickedView = (UIView *)arg1;
    if ([clickedView superview] != self.secondLineView ||
        [clickedView.superview.subviews indexOfObject:clickedView] != 1)
    {
        CHSuper1(AWEAwemeShareViewController, clicked, arg1);
        return;
    }
    
    AlertSheetAction firstAction = ^(void)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"whenReceivedCmdToSaveVideo" object:nil];
        UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.hidesWhenStopped = YES;
        activityView.tag = 20003;
        [[UIApplication sharedApplication].keyWindow addSubview:activityView];
        activityView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2.0, [UIScreen mainScreen].bounds.size.height/2.0);
        [activityView startAnimating];
        [self dismiss];
    };
    
    AlertSheetAction secondAction = ^(void)
    {
        CHSuper1(AWEAwemeShareViewController, clicked, arg1);
    };
    
    [Tool popSheetAlertOnVC:self withTitle:@"选择有无水印" andMessage:nil andFuncNames:@[@"无水印", @"有水印"] andActions:@[firstAction, secondAction]];
}

CHConstructor
{
    CHLoadLateClass(AWEAwemeShareViewController);
    CHHook1(AWEAwemeShareViewController, clicked);
}

CHDeclareClass(AWEAwemePlayVideoViewController)


CHOptimizedMethod0(self, void, AWEAwemePlayVideoViewController, restartPlayVideo)
{
    CHSuper0(AWEAwemePlayVideoViewController, restartPlayVideo);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(whenReceivedCmdToSaveVideo:) name:@"whenReceivedCmdToSaveVideo" object:nil];
}

CHDeclareMethod1(void, AWEAwemePlayVideoViewController, whenReceivedCmdToSaveVideo, NSNotification*, notification)
{
    [self tryToSaveVideoToAlbum];
}

CHOptimizedMethod0(self, void, AWEAwemePlayVideoViewController, reset)
{
    CHSuper0(AWEAwemePlayVideoViewController, reset);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"whenReceivedCmdToSaveVideo" object:nil];
}

CHDeclareMethod0(void, AWEAwemePlayVideoViewController, tryToSaveVideoToAlbum)
{
    NSLog(@"going to save: %@", self.playerController);
    IESSysPlayerWrapper* playerController = self.playerController;
    AWEVideoPlayerController* player = playerController.player;
    NSString* currentItemKey = player.currentItemKey;
    NSLog(@"currentItemKey: %@", currentItemKey);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* libraryPath = [paths objectAtIndex:0];
    NSString* videoPath = [NSString stringWithFormat:@"%@/AWEVideoCache/FileCache/%@", libraryPath, currentItemKey];
    NSLog(@"videoPath: %@", videoPath);
    NSString* videoPathWithExt = [videoPath stringByAppendingString:@".mp4"];
    NSError* copyError;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    [fileMgr copyItemAtPath:videoPath toPath:videoPathWithExt error:&copyError];
    if (copyError)
    {
        NSLog(@"更改视频文件失败");
        return;
    }
    NSLog(@"videoPath: %@", videoPath);
    //    __weak __typeof(&*self)weakSelf = self;
    [Tool saveToAlbumWithLocalVideoPath:videoPathWithExt andFinishHandler:^(BOOL isSuccessfull)
     {
         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void)
        {
            dispatch_async(dispatch_get_main_queue(), ^(void)
            {
                UIActivityIndicatorView* activityView = [[UIApplication sharedApplication].keyWindow viewWithTag:20003];
                [activityView stopAnimating];
                [activityView removeFromSuperview];
                activityView = nil;
            });
        });
         
         [fileMgr removeItemAtPath:videoPathWithExt error:nil];
         
         NSLog(@"saveToAlbumWithLocalVideoPath: %i", isSuccessfull);
     }];
}

CHConstructor
{
    CHLoadLateClass(AWEAwemePlayVideoViewController);
    CHHook0(AWEAwemePlayVideoViewController, reset);
    CHHook0(AWEAwemePlayVideoViewController, restartPlayVideo);
}

CHDeclareClass(CustomViewController)

CHOptimizedMethod(0, self, NSString*, CustomViewController,getMyName){
    return @"MonkeyDevPod";
}

CHConstructor{
    CHLoadLateClass(CustomViewController);
    CHClassHook(0, CustomViewController, getMyName);
}
