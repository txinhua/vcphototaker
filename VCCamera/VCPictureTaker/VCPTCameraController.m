//
//  VCPTCameraController.m
//  VCPictureTaker
//
//  Created by vcaiTech on 16-10-19.
//  Copyright (c) 2016年 Tangguifu. All rights reserved.
//

#import "VCPTCameraController.h"
#import "VCCaptureCameraController.h"
#import "VCPTMacroDefine.h"

@interface VCPTCameraController ()
@property (nonatomic, assign) BOOL isStatusBarHiddenBeforeShowCamera;
@end


@implementation VCPTCameraController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init{
    if (![VCPTPhotoUtils deviceSuppourtPhotoTake])
        return nil;
    self = [super init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationBarHidden = YES;
    self.hidesBottomBarWhenPushed = YES;
    _isStatusBarHiddenBeforeShowCamera = [UIApplication sharedApplication].statusBarHidden;
    if ([UIApplication sharedApplication].statusBarHidden == NO) {
        //iOS7，需要plist里设置 View controller-based status bar appearance 为NO
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)dealloc {
    //status bar
    if ([UIApplication sharedApplication].statusBarHidden != _isStatusBarHiddenBeforeShowCamera) {
        [[UIApplication sharedApplication] setStatusBarHidden:_isStatusBarHiddenBeforeShowCamera withAnimation:UIStatusBarAnimationSlide];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - pop
- (void)dismissModalViewControllerAnimated:(BOOL)animated {
    BOOL shouldToDismiss = YES;
    if ([self.cameraDelegate respondsToSelector:@selector(willDismissNavigationController:)]) {
        shouldToDismiss = [self.cameraDelegate willDismissNavigationController:self];
    }
    if (shouldToDismiss) {
        [super dismissModalViewControllerAnimated:animated];
    }
}

#pragma mark - action(s)
- (void)showCameraWithParentController:(UIViewController*)parentController {
    
    VCCaptureCameraController *con = [[VCCaptureCameraController alloc] init];
    [self setViewControllers:[NSArray arrayWithObjects:con, nil]];
    [parentController presentViewController:self animated:YES completion:nil];
}


@end
