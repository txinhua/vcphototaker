//
//  VCPhotoPreViewViewController.m
//  VCPictureTaker
//
//  Created by vcaiTech on 16-10-19.
//  Copyright (c) 2016年 Tangguifu. All rights reserved.
//

#import "VCPhotoPreViewViewController.h"
#import "VCPTCameraController.h"
#import "VCPTMacroDefine.h"

@interface VCPhotoPreViewViewController ()

@end

@implementation VCPhotoPreViewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor blackColor];
	// Do any additional setup after loading the view.
    if (_postImage) {
        UIImageView *imgView = [[UIImageView alloc] initWithImage:_postImage];
        imgView.clipsToBounds = YES;
        CGFloat imageHeight = SC_APP_SIZE.height-50;
        CGFloat imageWidth = SC_APP_SIZE.width*imageHeight/SC_APP_SIZE.height;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.frame = CGRectMake((SC_APP_SIZE.width-imageWidth)*0.5, 0,imageWidth,imageHeight);
        [self.view addSubview:imgView];
    }
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    backBtn.frame = CGRectMake(0, self.view.frame.size.height - 45, 80, 40);
    [backBtn setTitle:@"重新拍摄" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIButton *useBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    useBtn.frame = CGRectMake(self.view.frame.size.width-80, self.view.frame.size.height - 45, 80, 40);
    [useBtn setTitle:@"使用" forState:UIControlStateNormal];
    [useBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [useBtn addTarget:self action:@selector(useBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:useBtn];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)useBtnPressed:(UIButton *)sender {
    
    sender.enabled = NO;
    VCPTCameraController *nav = (VCPTCameraController*)self.navigationController;
    if ([nav.cameraDelegate respondsToSelector:@selector(usePicture:image:)]) {
        [nav.cameraDelegate usePicture:nav image:_postImage];
    }
    
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}






@end
