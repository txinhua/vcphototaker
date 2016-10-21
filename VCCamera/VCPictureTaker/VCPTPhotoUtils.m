//
//  SCALASsetUtils.m
//  HotCool2
//
//  Created by VcaiTec on 16/1/8.
//  Copyright © 2016年 Tang guifu. All rights reserved.
//

#import "VCPTPhotoUtils.h"
#import <UIKit/UIKit.h>

#if __IPHONE_8_0
#import <Photos/Photos.h>
#else
#import <AssetsLibrary/AssetsLibrary.h>
#endif

@interface VCPTPhotoUtils ()
#if __IPHONE_8_0
@property(nonatomic,retain)PHPhotoLibrary  *assetsLibrary;
#else
@property(nonatomic,retain)ALAssetsLibrary *assetsLibrary;
#endif
@end

@implementation VCPTPhotoUtils
+(BOOL)deviceSuppourtPhotoTake{
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    return [UIImagePickerController isSourceTypeAvailable:sourceType];
    
}

+(instancetype)shareInstance{
    static VCPTPhotoUtils *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[VCPTPhotoUtils alloc] init];
        #if __IPHONE_8_0
        _instance.assetsLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        #else
        _instance.assetsLibrary = [[ALAssetsLibrary alloc]init];
        #endif
        
    });
    return _instance;
}

-(void)saveImageToPhotoAlbum:(UIImage*)image block:(SavePhotoBlock)completionBlock{
    
    assert(completionBlock);
#if __IPHONE_8_0
    NSMutableArray *imageIds = [NSMutableArray array];
    
    [self.assetsLibrary performChanges:^{
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        //记录本地标识，等待完成后取到相册中的图片对象
        [imageIds addObject:req.placeholderForCreatedAsset.localIdentifier];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
        if (success){
            //成功后取相册中的图片对象
            PHAsset *imageAsset = nil;
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:imageIds options:nil];
            if (result) {
                imageAsset = result.firstObject;
            }
            
            if (imageAsset)
            {
                //加载图片数据
//                [[PHImageManager defaultManager] requestImageDataForAsset:imageAsset                           options:nil                           resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//                    
//                }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(imageAsset,nil);});
                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"Save Fail" code:10010 userInfo:nil];
                    completionBlock(nil,error);});
            }
        }
    }];
#else
    [self.assetsLibrary writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
        completionBlock(assetURL,error);
        });
    }];
#endif
    
}



@end
