//
//  VCPTPhotoUtils.h
//  VCPictureTaker
//
//  Created by VcaiTec on 16/10/19.
//  Copyright © 2016年 Tang guifu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^SavePhotoBlock)(id imageRefrence, NSError *error);

@interface VCPTPhotoUtils : NSObject

+(instancetype)shareInstance;
+(BOOL)deviceSuppourtPhotoTake;
-(void)saveImageToPhotoAlbum:(UIImage*)image block:(SavePhotoBlock)completionBlock;

@end
