//
//  VCPTCameraController.h
//  VCPictureTaker
//
//  Created by vcaiTech on 16-10-19.
//  Copyright (c) 2016年 Tangguifu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCPTPhotoUtils.h"

@protocol VCPTCameraDelegate;

@interface VCPTCameraController : UINavigationController

- (void)showCameraWithParentController:(UIViewController*)parentController;

@property (nonatomic, assign) id <VCPTCameraDelegate> cameraDelegate;

@end



@protocol VCPTCameraDelegate <NSObject>

@optional
- (BOOL)willDismissNavigationController:(VCPTCameraController*)navigatonController;
- (void)usePicture:(VCPTCameraController*)navigationController image:(UIImage*)image;
@end
