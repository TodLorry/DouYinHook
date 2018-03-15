//
//  PhotoTool.m
//  AirBrush
//
//  Created by albus on 2017/10/16.
//  Copyright © 2017年 Hippo. All rights reserved.
//

#import "Tool.h"
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

@implementation Tool

//弹出Sheet类型的弹出框
+ (void)popSheetAlertOnVC:(UIViewController*)vc withTitle:(NSString*)title andMessage:(NSString*)message andFuncNames:(NSArray*)funcNames andActions:(NSArray<AlertSheetAction>*)actions
{
    if (actions == nil || actions.count == 0 || funcNames == nil || funcNames.count == 0 || funcNames.count != actions.count)
    {
        return;
    }
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSInteger i = 0; i < actions.count; i++)
    {
        UIAlertAction* thisAction = [UIAlertAction actionWithTitle:[funcNames objectAtIndex:i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
                                     {
                                         AlertSheetAction theAction = [actions objectAtIndex:i];
                                         if (theAction)
                                         {
                                             theAction();
                                         }
                                     }];
        [alertController addAction:thisAction];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [vc presentViewController:alertController animated:YES completion:nil];
}

#pragma mark 保存视频到指定相册

//保存视频
+(void)saveToAlbumWithLocalVideoPath:(NSString*)locaoVideoPath andFinishHandler:(void (^) (BOOL isSuccessfull))theSuccess
{
    //1 将图片保存到系统的【相机胶卷】中---调用刚才的方法
    PHFetchResult<PHAsset *> *assets = [self syncSaveVideoWithLocalVideoPath:locaoVideoPath];
    
    if (assets == nil)
    {
        return;
    }
    
    //2 拥有自定义相册（与 APP 同名，如果没有则创建）--调用刚才的方法
    PHAssetCollection *assetCollection = [self getAssetCollectionWithAppNameAndCreateIfNo];
    if (assetCollection == nil) {
        NSLog(@"创建相册失败");
        return;
    }
    
    
    //3 将刚才保存到相机胶卷的图片添加到自定义相册中 --- 保存带自定义相册--属于增的操作，需要在PHPhotoLibrary的block中进行
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^(void)
    {
        //--告诉系统，要操作哪个相册
        PHAssetCollectionChangeRequest* collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        //--添加图片到自定义相册--追加--就不能成为封面了
        //--[collectionChangeRequest addAssets:assets];
        //--插入图片到自定义相册--插入--可以成为封面
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    
    if (error)
    {
        NSLog(@"插入视频到指定相册失败: %@", error);
    }
    else
    {
        if (theSuccess)
        {
            theSuccess(YES);
        }
    }
}

+(PHFetchResult<PHAsset *> *)syncSaveVideoWithLocalVideoPath:(NSString*)locaoVideoPath
{
    //--1 创建 ID 这个参数可以获取到图片保存后的 asset对象
    __block NSString *createdAssetID = @"";
    
    //--2 保存图片
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^(void)
    {
        //----block 执行的时候还没有保存成功--获取占位图片的 id，通过 id 获取图片---同步
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:locaoVideoPath ? locaoVideoPath : @""]].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    //--3 如果失败，则返回空
    if (error)
    {
        return nil;
    }
    //--4 成功后，返回对象
    //获取保存到系统相册成功后的 asset 对象集合，并返回
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    return assets;
}

//创建相册
+(PHAssetCollection *)getAssetCollectionWithAppNameAndCreateIfNo
{
    //1 命名相册
    NSString* title = @"抖音";
    //2 获取与 APP 同名的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        //遍历
        if ([collection.localizedTitle isEqualToString:title]) {
            //找到了同名的自定义相册--返回
            return collection;
        }
    }
    
    //说明没有找到，需要创建
    NSError *error = nil;
    __block NSString* createID = @""; //用来获取创建好的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //发起了创建新相册的请求，并拿到ID，当前并没有创建成功，待创建成功后，通过 ID 来获取创建好的自定义相册
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        return nil;
    }else{
        //通过 ID 获取创建完成的相册 -- 是一个数组
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
    }
}

@end
