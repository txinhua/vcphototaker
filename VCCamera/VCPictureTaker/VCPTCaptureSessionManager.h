//
//  VCPTCaptureSessionManager.h
//  VCPictureTaker
//
//  Created by VcaiTech on 2016/10/18.
//  Copyright © 2016年 Tang guifu. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#define MAX_PINCH_SCALE_NUM   4.f
#define MIN_PINCH_SCALE_NUM   1.f

typedef void(^DidCapturePhotoBlock)(UIImage *stillImage);

@interface VCPTCaptureSessionManager : NSObject

@property(nonatomic) dispatch_queue_t sessionQueue;
@property(nonatomic,strong)AVCaptureSession*captureSession;
@property(nonatomic,strong)AVCaptureDevice*captureDevice;
@property(nonatomic,strong)AVCaptureDeviceInput*captureDeviceInput;
@property(nonatomic,strong)AVCaptureStillImageOutput*stillImageOutput;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer*videoPreviewLayer;

@property (nonatomic, assign) CGFloat preScaleNum;
@property (nonatomic, assign) CGFloat scaleNum;
//拍照成功后的回调
@property (nonatomic,copy)DidCapturePhotoBlock completion;

- (void)configureWithParentLayer:(UIView*)parent previewRect:(CGRect)preivewRect;
- (void)takePicture;
- (void)switchCamera:(BOOL)isFrontCamera;
- (void)pinchCameraViewWithScalNum:(CGFloat)scale;
- (void)pinchCameraView:(UIPinchGestureRecognizer*)gesture;
- (void)switchFlashMode:(UIButton*)sender;
- (void)focusInPoint:(CGPoint)devicePoint;

@end
