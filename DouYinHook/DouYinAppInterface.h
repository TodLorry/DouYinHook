//
//  DouYinAppInterface.h
//  DouYinApp
//
//  Created by albus on 2018/3/11.
//  Copyright © 2018年 albus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTDShareBaseViewController : UIViewController
@end

@interface AWEAwemeShareViewController : BTDShareBaseViewController

@property(retain, nonatomic) UIScrollView *secondLineView;

- (void)clicked:(id)arg1;
- (void)dismiss;

@end

@protocol IESVideoPlayerProtocol <NSObject>
@end

@interface AWEVideoPlayerController : NSObject

@property(copy, nonatomic) NSString *currentItemKey;

@end

@interface IESSysPlayerWrapper : NSObject

@property(retain, nonatomic) AWEVideoPlayerController *player;

@end

@interface AWEAwemePlayVideoViewController : UIViewController

@property(retain, nonatomic) id <IESVideoPlayerProtocol> playerController;

- (void)tryToSaveVideoToAlbum;
- (void)reset;
- (void)whenReceivedCmdToSaveVideo:(NSNotification *)notification;
- (void)restartPlayVideo;

@end

#ifndef DouYinAppInterface_h
#define DouYinAppInterface_h


#endif /* DouYinAppInterface_h */
