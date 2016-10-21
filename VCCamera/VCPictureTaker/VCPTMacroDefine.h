//
//  VCPTMacroDefine.h
//  VCPictureTaker
//
//  Created by VcaiTech on 2016/10/18.
//  Copyright © 2016年 Tang guifu. All rights reserved.
//

#ifndef VCPTMacroDefine_h
#define VCPTMacroDefine_h

// Debug Logging
#if 1 // Set to 1 to enable debug logging
#define SCDLog(x, ...) NSLog(x, ## __VA_ARGS__);
#else
#define SCDLog(x, ...)
#endif

#define IOS8UP ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8?YES:NO)

//notification
#define kCapturedPhotoSuccessfully              @"caputuredPhotoSuccessfully"
#define kNotificationOrientationChange          @"kNotificationOrientationChange"
#define kNotificationTakePicture  @"kNotificationTakePicture"

#define kImage                                  @"image"
#define kFilterImage                            @"image"
#define kAudioAmrName                           @"amrName"
#define kAudioDuration                          @"audioDuration"

//weakself
#define WEAKSELF_SC __weak __typeof(&*self)weakSelf_SC = self;


//cort text里的空格要转一下
#define REPLACE_SPACE_STR(content) [content stringByReplacingOccurrencesOfString:@" " withString:@" "]

//color
#define rgba_SC(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

//frame and size
#define SC_DEVICE_BOUNDS    [[UIScreen mainScreen] bounds]
#define SC_DEVICE_SIZE      [[UIScreen mainScreen] bounds].size

#define SC_APP_FRAME        [[UIScreen mainScreen] bounds]
#define SC_APP_SIZE         [[UIScreen mainScreen] bounds].size

#define SELF_CON_FRAME      self.view.frame
#define SELF_CON_SIZE       self.view.frame.size
#define SELF_VIEW_FRAME     self.frame
#define SELF_VIEW_SIZE      self.frame.size

#define SC_APP_BOTTOM_HEIGHT 134

// 是否iPad
#define isPad_SC (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)//设备类型改为Universal才能生效
#define isPad_AllTargetMode_SC ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound)//设备类型为任何类型都能生效

//iPhone5及以上设备，按钮的位置放在下面。iPhone5以下的按钮放上面。
#define isHigherThaniPhone4_SC ((isPad_AllTargetMode_SC && [[UIScreen mainScreen] applicationFrame].size.height <= 960 ? NO : ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ([[UIScreen mainScreen] currentMode].size.height > 960 ? YES : NO) : NO)))

#   define kTextAlignmentCenter_SC    NSTextAlignmentCenter
#   define kTextAlignmentLeft_SC      NSTextAlignmentLeft
#   define kTextAlignmentRight_SC     NSTextAlignmentRight

#   define kTextLineBreakByWordWrapping_SC      NSLineBreakByWordWrapping
#   define kTextLineBreakByCharWrapping_SC      NSLineBreakByCharWrapping
#   define kTextLineBreakByClipping_SC          NSLineBreakByClipping
#   define kTextLineBreakByTruncatingHead_SC    NSLineBreakByTruncatingHead
#   define kTextLineBreakByTruncatingTail_SC    NSLineBreakByTruncatingTail
#   define kTextLineBreakByTruncatingMiddle_SC  NSLineBreakByTruncatingMiddle

#endif /* VCPTMacroDefine_h */
