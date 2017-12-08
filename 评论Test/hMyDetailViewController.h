//
//  hMyDetailViewController.h
//  评论Test
//
//  Created by 伯驹网络 on 2017/11/30.
//  Copyright © 2017年 Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHMessageInputView.h"
#import "XHEmotionManagerView.h"

#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);
#define KEYBOARD_height 50.0;

@interface hMyDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,XHMessageInputViewDelegate,XHEmotionManagerViewDelegate, XHEmotionManagerViewDataSource>

/**
 *  用于显示发送消息类型控制的工具条，在底部
 */
@property (nonatomic,strong)XHMessageInputView *inputView;
@property (nonatomic, assign) XHInputViewType textViewInputViewType;
@property (nonatomic, assign) XHMessageInputViewStyle inputViewStyle;
@property (nonatomic, strong) NSArray *emotionManagers;
@property (strong, nonatomic) NSDictionary * facesDic;
@property (strong, nonatomic) NSArray *facesAry;
@property (nonatomic,strong) NSArray *faceNUmArr;

/**
 *  管理第三方gif表情的控件
 */
@property (nonatomic, weak, readonly) XHEmotionManagerView *emotionManagerView;
/**
 *  是否支持发送表情
 */
@property (nonatomic, assign) BOOL allowsSendFace; // default is YES

/**
 *  是否允许手势关闭键盘，默认是允许
 */
@property (nonatomic, assign) BOOL allowsPanToDismissKeyboard; // default is YES

@end
