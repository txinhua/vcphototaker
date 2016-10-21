//
//  ViewController.m
//  VCPictureTakerDemo
//
//  Created by VcaiTech on 2016/10/18.
//  Copyright © 2016年 Tang guifu. All rights reserved.
//

#import "ViewController.h"
#import "VCPTCameraController.h"
@interface ViewController ()<VCPTCameraDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(id)sender {
    VCPTCameraController *cameraC =  [[VCPTCameraController alloc]init];
    if (cameraC) {
        cameraC.cameraDelegate = self;
        [cameraC showCameraWithParentController:self];
    }else{
        NSLog(@"该设备不支持拍照");
    }
}

-(void)usePicture:(VCPTCameraController *)navigationController image:(UIImage *)image{
    
    if (image) {
//        __weak ViewController *weakSekf = self;
        [[VCPTPhotoUtils shareInstance]saveImageToPhotoAlbum:image block:^(id imageRefrence, NSError *error) {
            //加载相应的图片到所需的页面
            
            [navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }else{
        [navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}







@end
