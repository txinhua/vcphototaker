//
//  VCCaptureCameraController.m
//  VCPictureTaker
//
//  Created by vcaiTech on 16-10-19.
//  Copyright (c) 2016年 Tangguifu. All rights reserved.
//

#import "VCCaptureCameraController.h"
#import "VCPTCaptureSessionManager.h"
#import "VCPhotoPreViewViewController.h"
#import "VCPTMacroDefine.h"
#import "VCPTSlider.h"

#define SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE      0  //对焦框是否一直闪到对焦完成

#define SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA   0   //没有拍照功能的设备，是否给一张默认图片体验一下

//height
#define CAMERA_TOPVIEW_HEIGHT   64  //title
#define CAMERA_MENU_VIEW_HEIGH  44  //menu

//color
#define bottomContainerView_UP_COLOR     [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.f]       //bottomContainerView的上半部分
#define bottomContainerView_DOWN_COLOR   [UIColor colorWithRed:68/255.0f green:68/255.0f blue:68/255.0f alpha:1.f]       //bottomContainerView的下半部分
#define DARK_GREEN_COLOR        [UIColor colorWithRed:10/255.0f green:107/255.0f blue:42/255.0f alpha:1.f]    //深绿色
#define LIGHT_GREEN_COLOR       [UIColor colorWithRed:143/255.0f green:191/255.0f blue:62/255.0f alpha:1.f]    //浅绿色


//对焦
#define ADJUSTINT_FOCUS @"adjustingFocus"
#define LOW_ALPHA   0.7f
#define HIGH_ALPHA  1.0f

@interface VCCaptureCameraController () {
    int alphaTimes;
    CGPoint currTouchPoint;
    BOOL isPinGesture;
}

@property (nonatomic, strong) VCPTCaptureSessionManager *captureManager;

@property (nonatomic, strong) UIView *topContainerView;//顶部view
@property (nonatomic, strong) UIView *bottomContainerView;//除了顶部标题、拍照区域剩下的所有区域
@property (nonatomic, strong) UIView *cameraMenuView;//网格、闪光灯、前后摄像头等按钮
@property (nonatomic, strong) NSMutableSet *cameraBtnSet;

@property (nonatomic, strong) UIView *doneCameraUpView;
@property (nonatomic, strong) UIView *doneCameraDownView;
//对焦
@property (nonatomic, strong) UIImageView *focusImageView;

@property (nonatomic, strong) VCPTSlider *scSlider;

@end

@implementation VCCaptureCameraController

#pragma mark -------------life cycle---------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        alphaTimes = -1;
        currTouchPoint = CGPointZero;
        _cameraBtnSet = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //navigation bar
    if (self.navigationController && !self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = YES;
    }
    
    _isStatusBarHiddenBeforeShowCamera = YES;
    
    //notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:kNotificationOrientationChange object:nil];
    
    //session manager
    VCPTCaptureSessionManager *manager = [[VCPTCaptureSessionManager alloc] init];
    WEAKSELF_SC
    [manager setCompletion:^(UIImage *stillImage) {
        [weakSelf_SC showPhotoPreviewWithImage:stillImage];
    }];
    //AvcaptureManager
    if (CGRectEqualToRect(_previewRect, CGRectZero)) {
        self.previewRect = CGRectMake(0, 0, SC_APP_SIZE.width, SC_APP_SIZE.height);
    }
    
    [manager configureWithParentLayer:self.view previewRect:_previewRect];
    self.captureManager = manager;
    
    [self addTopView];
    [self addbottomContainerView];
    [self addCameraMenuView];
    [self addFocusView];
    [self addCameraCover];
    [self addPinchGesture];
    [_captureManager.captureSession startRunning];
    
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
      
    }
#endif
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    if (!self.navigationController) {
        if ([UIApplication sharedApplication].statusBarHidden != _isStatusBarHiddenBeforeShowCamera) {
            [[UIApplication sharedApplication] setStatusBarHidden:_isStatusBarHiddenBeforeShowCamera withAnimation:UIStatusBarAnimationSlide];
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationOrientationChange object:nil];
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device removeObserver:self forKeyPath:ADJUSTINT_FOCUS context:nil];
    }
#endif
    
    self.captureManager = nil;
}

#pragma mark -------------UI---------------
//顶部标题
- (void)addTopView{
    if (!_topContainerView) {
        
        CGRect topFrame = CGRectMake(0, 0, SC_APP_SIZE.width, CAMERA_TOPVIEW_HEIGHT);
        UIView *tView = [[UIView alloc] initWithFrame:topFrame];
        tView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tView];
        self.topContainerView = tView;
        
    }
}

//bottomContainerView，总体
- (void)addbottomContainerView {
    
    CGRect bottomFrame = CGRectMake(0, SC_APP_SIZE.height - SC_APP_BOTTOM_HEIGHT, SC_APP_SIZE.width, SC_APP_BOTTOM_HEIGHT);
    
    UIView *view = [[UIView alloc] initWithFrame:bottomFrame];
    view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view];
    self.bottomContainerView = view;
}

//拍照菜单栏
- (void)addCameraMenuView {
    
    CGFloat cameraBtnLength = 76;
    UIButton *takeBtn =  [self buildButton:CGRectMake((SC_APP_SIZE.width - cameraBtnLength) / 2, (_bottomContainerView.frame.size.height  - cameraBtnLength) / 2 , cameraBtnLength, cameraBtnLength)
         normalImgStr:@"vc_photo_take"
      highlightImgStr:@"vc_photo_take"
       selectedImgStr:@""
               action:@selector(takePictureBtnPressed:)
           parentView:_bottomContainerView];
    UILabel *optionLabel =[[UILabel alloc]initWithFrame:CGRectMake(0, takeBtn.frame.origin.y-28, SC_APP_SIZE.width, 20)];
    optionLabel.backgroundColor =[UIColor clearColor];
    optionLabel.textAlignment = NSTextAlignmentCenter;
    optionLabel.textColor =[UIColor whiteColor];
    optionLabel.font =[UIFont boldSystemFontOfSize:18];
    optionLabel.text = @"点击拍照";
    [_bottomContainerView addSubview:optionLabel];
    [self addMenuViewButtons];
}

//拍照菜单栏上的按钮
- (void)addMenuViewButtons {
    //判断设备是否有闪光灯然后决定是否添加闪光灯切换按钮
    UIButton * btn_cancel = [self buildButton:CGRectMake(16, 27, 30, 30)
                          normalImgStr:@"vc_video_icon_close"
                       highlightImgStr:@""
                        selectedImgStr:@""
                                action:NSSelectorFromString(@"dismissBtnPressed:")
                            parentView:_topContainerView];
    
    btn_cancel.showsTouchWhenHighlighted = YES;
    
    [_cameraBtnSet addObject:btn_cancel];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [device lockForConfiguration:nil];
    if ([device hasFlash]) {
        UIButton * btn = [self buildButton:CGRectMake(_topContainerView.frame.size.width-90, 27, 30, 30)
                              normalImgStr:@"vc_video_flash_off"
                           highlightImgStr:@""
                            selectedImgStr:@""
                                    action:NSSelectorFromString(@"flashBtnPressed:")
                                parentView:_topContainerView];
        
        btn.showsTouchWhenHighlighted = YES;
        btn.tag = 5555;
        [_cameraBtnSet addObject:btn];
    }
    
    UIButton * btn_switch = [self buildButton:CGRectMake(_topContainerView.frame.size.width-44, 27, 30, 30)
                          normalImgStr:@"vc_video_device_change"
                       highlightImgStr:@""
                        selectedImgStr:@""
                                action:NSSelectorFromString(@"switchCameraBtnPressed:")
                            parentView:_topContainerView];
    
    btn_switch.showsTouchWhenHighlighted = YES;
    
    [_cameraBtnSet addObject:btn_switch];
    
}

- (UIButton*)buildButton:(CGRect)frame
            normalImgStr:(NSString*)normalImgStr
         highlightImgStr:(NSString*)highlightImgStr
          selectedImgStr:(NSString*)selectedImgStr
                  action:(SEL)action
              parentView:(UIView*)parentView {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (normalImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:normalImgStr] forState:UIControlStateNormal];
    }
    if (highlightImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:highlightImgStr] forState:UIControlStateHighlighted];
    }
    if (selectedImgStr.length > 0) {
        [btn setImage:[UIImage imageNamed:selectedImgStr] forState:UIControlStateSelected];
    }
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:btn];
    
    return btn;
}

//对焦的框
- (void)addFocusView {
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vc_touch_focus_x"]];
    imgView.alpha = 0;
    [self.view addSubview:imgView];
    self.focusImageView = imgView;
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device && [device isFocusPointOfInterestSupported]) {
        [device addObserver:self forKeyPath:ADJUSTINT_FOCUS options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
#endif
}

//拍完照后的遮罩
- (void)addCameraCover {
    UIView *upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.topContainerView.frame.size.width,self.topContainerView.frame.size.height)];
    upView.alpha = 0;
    upView.backgroundColor = [UIColor clearColor];
    [self.topContainerView addSubview:upView];
    self.doneCameraUpView = upView;
    
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bottomContainerView.frame.size.width, self.bottomContainerView.frame.size.height)];
    downView.alpha = 0;
    downView.backgroundColor = [UIColor clearColor];
    
    [self.bottomContainerView addSubview:downView];
    self.doneCameraDownView = downView;
}

- (void)showCameraCover:(BOOL)toShow {
    if (toShow) {
        [UIView animateWithDuration:0.3f animations:^{
            
            _doneCameraUpView.alpha = 1.0f;
            
            _doneCameraDownView.alpha = 1.0f;
        }];
    }else{
        [UIView animateWithDuration:0.3f animations:^{
            
            _doneCameraUpView.alpha = .0f;
            
            _doneCameraDownView.alpha = .0f;
        }];
    }
    
}

//伸缩镜头的手势
- (void)addPinchGesture {
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.view addGestureRecognizer:pinch];
    
    //横向
    CGFloat width = _previewRect.size.width - 60;
    CGFloat height = 40;
    VCPTSlider *slider = [[VCPTSlider alloc] initWithFrame:CGRectMake((SC_APP_SIZE.width - width) / 2, SC_APP_SIZE.height - SC_APP_BOTTOM_HEIGHT - height, width, height)];
    slider.alpha = 0.f;
    slider.minValue = MIN_PINCH_SCALE_NUM;
    slider.maxValue = MAX_PINCH_SCALE_NUM;
    
    WEAKSELF_SC
    [slider buildDidChangeValueBlock:^(CGFloat value) {
        [weakSelf_SC.captureManager pinchCameraViewWithScalNum:value];
    }];
    [slider buildTouchEndBlock:^(CGFloat value, BOOL isTouchEnd) {
        [weakSelf_SC setSliderAlpha:isTouchEnd];
    }];
    
    [self.view addSubview:slider];
    
    self.scSlider = slider;
}

void c_slideAlpha() {
    
}

- (void)setSliderAlpha:(BOOL)isTouchEnd {
    if (_scSlider) {
        _scSlider.isSliding = !isTouchEnd;
        if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
            double delayInSeconds = 3.88;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (_scSlider.alpha != 0.f && !_scSlider.isSliding) {
                    [UIView animateWithDuration:0.3f animations:^{
                        _scSlider.alpha = 0.f;
                    }];
                }
            });
        }
    }
}

#pragma mark -------------touch to focus---------------
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
//监听对焦是否完成了
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:ADJUSTINT_FOCUS]) {
        BOOL isAdjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        if (!isAdjustingFocus) {
            alphaTimes = -1;
        }
    }
}

- (void)showFocusInPoint:(CGPoint)touchPoint {
    
    [UIView animateWithDuration:0.1f delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        int alphaNum = (alphaTimes % 2 == 0 ? HIGH_ALPHA : LOW_ALPHA);
        self.focusImageView.alpha = alphaNum;
        alphaTimes++;
        
    } completion:^(BOOL finished) {
        
        if (alphaTimes != -1) {
            [self showFocusInPoint:currTouchPoint];
        } else {
            self.focusImageView.alpha = 0.0f;
        }
    }];
}
#endif

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    alphaTimes = -1;
    
    UITouch *touch = [touches anyObject];
    if (touch.tapCount>1) {
        return;
    }
    currTouchPoint = [touch locationInView:self.view];
    
    if (CGRectContainsPoint(_captureManager.videoPreviewLayer.frame, currTouchPoint) == NO||currTouchPoint.y<CAMERA_TOPVIEW_HEIGHT*2||currTouchPoint.y>_bottomContainerView.frame.origin.y-40) {
        return;
    }
    
    [_captureManager focusInPoint:currTouchPoint];
    
    //对焦框
    [_focusImageView setCenter:currTouchPoint];
    _focusImageView.transform = CGAffineTransformMakeScale(2.0, 2.0);
    
#if SWITCH_SHOW_FOCUSVIEW_UNTIL_FOCUS_DONE
    [UIView animateWithDuration:0.1f animations:^{
        _focusImageView.alpha = HIGH_ALPHA;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [self showFocusInPoint:currTouchPoint];
    }];
#else
    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        _focusImageView.alpha = 1.f;
        _focusImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f delay:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
            _focusImageView.alpha = 0.f;
        } completion:nil];
    }];
#endif
}

#pragma mark -------------button actions---------------
//拍照页面，拍照按钮
- (void)takePictureBtnPressed:(UIButton*)sender {
    
#if SWITCH_SHOW_DEFAULT_IMAGE_FOR_NONE_CAMERA
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [SVProgressHUD showErrorWithStatus:@"设备不支持拍照功能T_T"];
        return;
    }
#endif
    
    [self showCameraCover:YES];
    [_captureManager takePicture];
    
//    WEAKSELF_SC
//    [_captureManager takePicture:^(UIImage *stillImage) {
//        
////        [SCCommon saveImageToPhotoAlbum:stillImage :^(NSURL *assetURL, NSError *error) {
//        
//            [actiView stopAnimating];
//            [actiView removeFromSuperview];
//            actiView = nil;
//            
//            double delayInSeconds = 0.01f;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                sender.userInteractionEnabled = YES;
//                [weakSelf_SC showCameraCover:NO];
//            });
//            if (stillImage) {
//                SCNavigationController *nav = (SCNavigationController*)weakSelf_SC.navigationController;
//                if ([nav.scNaigationDelegate respondsToSelector:@selector(didTakePicture:image:)]) {
//                    [nav.scNaigationDelegate didTakePicture:nav image:stillImage];
//                }
//            }
////        }];
//    }];
}

- (void)tmpBtnPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//拍照页面，"X"按钮
- (void)dismissBtnPressed:(id)sender {
    
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count == 1) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

//拍照页面，切换前后摄像头按钮按钮
- (void)switchCameraBtnPressed:(UIButton*)sender {
    
    sender.selected = !sender.selected;
    [_cameraBtnSet enumerateObjectsUsingBlock:^(UIButton *obj, BOOL * stop) {
        if (obj.tag==5555) {
            obj.hidden =sender.selected;
            *stop = YES;
        }
    }];
    [_captureManager switchCamera:sender.selected];
}

//拍照页面，闪光灯按钮
- (void)flashBtnPressed:(UIButton*)sender {
    [_captureManager switchFlashMode:sender];
}

#pragma mark -------------pinch camera---------------
//伸缩镜头
- (void)handlePinch:(UIPinchGestureRecognizer*)gesture {
    [_captureManager pinchCameraView:gesture];
    
    if (_scSlider) {
        if (_scSlider.alpha != 1.f) {
            [UIView animateWithDuration:0.3f animations:^{
                _scSlider.alpha = 1.f;
            }];
        }
        [_scSlider setValue:_captureManager.scaleNum shouldCallBack:NO];
        
        if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
            [self setSliderAlpha:YES];
        } else {
            [self setSliderAlpha:NO];
        }
    }
}

//拍照完成展示所拍照片
-(void)showPhotoPreviewWithImage:(UIImage *)stillImage{
    
    if (stillImage) {
        VCPhotoPreViewViewController *photoPreView =[[VCPhotoPreViewViewController alloc]init];
        photoPreView.postImage = stillImage;
        [self.navigationController pushViewController:photoPreView animated:NO];
    }
    [self showCameraCover:NO];

}

#pragma mark ------------notification-------------
- (void)orientationDidChange:(NSNotification*)noti {
    
    if (!_cameraBtnSet || _cameraBtnSet.count <= 0) {
        return;
    }
    [_cameraBtnSet enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        UIButton *btn = ([obj isKindOfClass:[UIButton class]] ? (UIButton*)obj : nil);
        if (!btn) {
            *stop = YES;
            return ;
        }
        
        btn.layer.anchorPoint = CGPointMake(0.5, 0.5);
        CGAffineTransform transform = CGAffineTransformMakeRotation(0);
        switch ([UIDevice currentDevice].orientation) {
            case UIDeviceOrientationPortrait://1
            {
                transform = CGAffineTransformMakeRotation(0);
                break;
            }
            case UIDeviceOrientationPortraitUpsideDown://2
            {
                transform = CGAffineTransformMakeRotation(M_PI);
                break;
            }
            case UIDeviceOrientationLandscapeLeft://3
            {
                transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
            }
            case UIDeviceOrientationLandscapeRight://4
            {
                transform = CGAffineTransformMakeRotation(-M_PI_2);
                break;
            }
            default:
                break;
        }
        [UIView animateWithDuration:0.3f animations:^{
            btn.transform = transform;
        }];
    }];
}

- (BOOL)shouldAutorotate
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOrientationChange object:nil];
    return NO;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationPortrait;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
