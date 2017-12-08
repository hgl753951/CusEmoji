//
//  XHMessageInputView.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-4-24.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHMessageInputView.h"
//#import "XHMessageTableViewController.h"
//#import "NSString+MessageInputView.h"
//#import "XHMacro.h"

#define kXHTouchToRecord         @"按住 说话"
#define kXHTouchToFinish         @"松开 结束"

@interface XHMessageInputView () <UITextViewDelegate>

@property (nonatomic, weak, readwrite) XHMessageTextView *inputTextView;

@property (nonatomic, weak, readwrite) UIButton *voiceChangeButton;

@property (nonatomic, weak, readwrite) UIButton *multiMediaSendButton;

@property (nonatomic, weak, readwrite) UIButton *faceSendButton;

@property (nonatomic, weak, readwrite) UIButton *holdDownButton;

/**
 *  在切换语音和文本消息的时候，需要保存原本已经输入的文本，这样达到一个好的UE
 */
@property (nonatomic, copy) NSString *inputedText;
/**
 *  输入框内的所有按钮，点击事件所触发的方法
 *
 *  @param sender 被点击的按钮对象
 */
- (void)messageStyleButtonClicked:(UIButton *)sender;

/**
 *  当录音按钮被按下所触发的事件，这时候是开始录音
 */
- (void)holdDownButtonTouchDown;

/**
 *  当手指在录音按钮范围之外离开屏幕所触发的事件，这时候是取消录音
 */
- (void)holdDownButtonTouchUpOutside;

/**
 *  当手指在录音按钮范围之内离开屏幕所触发的事件，这时候是完成录音
 */
- (void)holdDownButtonTouchUpInside;

/**
 *  当手指滑动到录音按钮的范围之外所触发的事件
 */
- (void)holdDownDragOutside;

/**
 *  当手指滑动到录音按钮的范围之内所触发的时间
 */
- (void)holdDownDragInside;

#pragma mark - layout subViews UI
/**
 *  根据正常显示和高亮状态创建一个按钮对象
 *
 *  @param image   正常显示图
 *  @param hlImage 高亮显示图
 *
 *  @return 返回按钮对象
 */
- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage setimageEdge:(UIImage *)edgeImage setHLImageEdge:(UIImage *)hlImageEdge;

/**
 *  根据输入框的样式类型配置输入框的样式和UI布局
 *
 *  @param style 输入框样式类型
 */
- (void)setupMessageInputViewBarWithStyle:(XHMessageInputViewStyle)style ;

/**
 *  配置默认参数
 */
- (void)setup ;

#pragma mark - Message input view
/**
 *  动态改变textView的高度
 *
 *  @param changeInHeight 动态的高度
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

@end

@implementation XHMessageInputView

#pragma mark - Action

- (void)messageStyleButtonClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    switch (index) {
        case 0: {
             BOOL isSend = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSend"];
             sender.selected = !sender.selected;
            if (sender.selected) {
               
                if (isSend == YES) {
//                    self.sendBtn.hidden = YES;
                    self.multiMediaSendButton.hidden = NO;
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isSend"];
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"selectSendBtn"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }

                self.inputedText = self.inputTextView.text;
                self.inputTextView.text = @"";
                [self.inputTextView resignFirstResponder];
            } else {
                if (isSend == NO) {
                    self.sendBtn.hidden = NO;
                    self.multiMediaSendButton.hidden = YES;
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSend"];
                   
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
 
                self.inputTextView.text = self.inputedText;
                self.inputedText = nil;
                [self.inputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.holdDownButton.alpha = sender.selected;
                self.inputTextView.alpha = !sender.selected;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
                [self.delegate didChangeSendVoiceAction:sender.selected];
            }
            
            break;
        }
        case 1: {
            sender.selected = !sender.selected;
            self.voiceChangeButton.selected = !sender.selected;
            
            if (!sender.selected) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.holdDownButton.alpha = sender.selected;
                    self.inputTextView.alpha = !sender.selected;
                } completion:^(BOOL finished) {
                    
                }];
//                BOOL isSendFace = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSendFace"];
//                if (isSendFace == NO) {
//                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSendFace"];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                }
            } else {
              
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.holdDownButton.alpha = !sender.selected;
                    self.inputTextView.alpha = sender.selected;
                } completion:^(BOOL finished) {
                    
                }];
            }
          
            if ([self.delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                [self.delegate didSendFaceAction:sender.selected];
            }
            break;
        }
        case 2: {
          
                self.faceSendButton.selected = NO;
                if ([self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction)]) {
                    [self.delegate didSelectedMultipleMediaAction];
                }
            
            break;
        }
        case 3:{
            BOOL isSend = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSend"];
            if (isSend == YES) {
                self.multiMediaSendButton.hidden = NO;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isSend"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
                [self.delegate didSendTextAction:self.inputTextView.text];
                //  self.sendBtn.hidden = YES;
                
            }

        
        }
        default:
            break;
    }
}

- (void)holdDownButtonTouchDown {
    if ([self.delegate respondsToSelector:@selector(didStartRecordingVoiceAction)]) {
        [self.delegate didStartRecordingVoiceAction];
    }
}

- (void)holdDownButtonTouchUpOutside {
    if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
        [self.delegate didCancelRecordingVoiceAction];
    }
}

- (void)holdDownButtonTouchUpInside {
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction)]) {
        [self.delegate didFinishRecoingVoiceAction];
    }
}

- (void)holdDownDragOutside {
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction)]) {
        [self.delegate didDragOutsideAction];
    }
}

- (void)holdDownDragInside {
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction)]) {
        [self.delegate didDragInsideAction];
    }
}

#pragma mark - layout subViews UI

- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage setimageEdge:(UIImage *)edgeImage setHLImageEdge:(UIImage *)hlImageEdge{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [XHMessageInputView textViewLineHeight], [XHMessageInputView textViewLineHeight])];
    if (image)
        [button setBackgroundImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setBackgroundImage:hlImage forState:UIControlStateHighlighted];
    if (edgeImage) {
        [button setImage:edgeImage forState:UIControlStateNormal];
        [button setImage:hlImage forState:UIControlStateHighlighted];
        [button setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
   
    }
    return button;
}

- (void)setupMessageInputViewBarWithStyle:(XHMessageInputViewStyle)style {
//    XHMessageTableViewController *messageTableVC = [[XHMessageTableViewController alloc] init];
//    messageTableVC.delegate=self;
//    messageTableVC.dataSource = self;

    // 配置输入工具条的样式和布局
    
    // 需要显示按钮的总宽度，包括间隔在内
    CGFloat allButtonWidth = 0.0;
    
    // 水平间隔
    CGFloat horizontalPadding = 8;
    
    // 垂直间隔
    CGFloat verticalPadding = 5;
    
    // 输入框
    CGFloat textViewLeftMargin = ((style == XHMessageInputViewStyleFlat) ? 6.0 : 4.0);
    
    // 每个按钮统一使用的frame变量
    CGRect buttonFrame;
    
    // 按钮对象消息
    UIButton *button;
    
    // 允许发送表情
    if (self.allowsSendFace) {
        
        UIImage *emimg = [UIImage imageNamed:@"chatting_biaoqing_btn_normal"];
        
        button = [self createButtonWithImage:[UIImage imageNamed:@""] HLImage:[UIImage imageNamed:@""]setimageEdge:emimg setHLImageEdge:[UIImage imageNamed:@""]];
        
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setImageEdgeInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(horizontalPadding, verticalPadding);
//        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2.5;
        button.frame = buttonFrame;
        [self addSubview:button];
        allButtonWidth += CGRectGetMaxX(buttonFrame);
        textViewLeftMargin += CGRectGetMaxX(buttonFrame);
        self.faceSendButton = button;
    }
    
    self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sendBtn.frame = CGRectMake(MainScreen_width-60, 5, 50, 40);
//    self.sendBtn.backgroundColor = Color(41, 134, 98);
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendBtn setImage:[UIImage imageNamed:@"ico_Send_message_cannot"] forState:UIControlStateNormal];
    [self.sendBtn setImage:[UIImage imageNamed:@"ico_Send_message_hover"] forState:UIControlStateSelected];

//    [self.sendBtn setBackgroundImage:[UIImage imageNamed:@"tabbar_send_btn"] forState:UIControlStateNormal];
//    [self.sendBtn setBackgroundImage:[UIImage imageNamed:@"tabbar_send_btn_selected"] forState:UIControlStateSelected];
//    self.sendBtn.layer.cornerRadius = 3.0;
//    [self.sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendBtn addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.sendBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 5);
    
    self.sendBtn.tag = 3;
    self.sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
//    self.sendBtn.hidden = YES;
    [self addSubview:self.sendBtn];
    
    allButtonWidth+=self.sendBtn.frame.size.width+20;
    // 输入框的高度和宽度
    CGFloat width = CGRectGetWidth(self.bounds) - (allButtonWidth ? allButtonWidth : (textViewLeftMargin * 2));
    CGFloat height = [XHMessageInputView textViewLineHeight];
    
    // 初始化输入框
    XHMessageTextView *textView = [[XHMessageTextView  alloc] initWithFrame:CGRectZero];
    
    // 这个是仿微信的一个细节体验
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    
//    textView.placeHolder = @"发送新消息";
    textView.delegate = self;
       //添加边框
    //[textView.layer setMasksToBounds:YES];
    //设置边框圆角的弧度
    //[textView.layer setCornerRadius:5.0];
//    textView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    textView.layer.borderWidth = 2.0f;
//    [textView.layer setMasksToBounds:YES];
    [self addSubview:textView];
	_inputTextView = textView;
    
    // 配置不同iOS SDK版本的样式
    
    UIImageView *textBgView = [[UIImageView alloc]initWithFrame:CGRectMake(textViewLeftMargin-2, 8, width+4, 34)];
    
    UIImage *putImg = [UIImage imageNamed:@"press_for_audio"];
     textBgView.image = putImg;
    [self addSubview:textBgView];
    _inputTextView.frame = CGRectMake(textViewLeftMargin, 10.0f, width, height-6);
    _inputTextView.backgroundColor = [UIColor clearColor];
    [self bringSubviewToFront:_inputTextView];
}

#pragma mark - Life cycle

- (void)setup {
       // 配置自适应
//    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    // 由于继承UIImageView，所以需要这个属性设置
    self.userInteractionEnabled = YES;
   
    // 默认设置
    _allowsSendVoice = YES;
    _allowsSendFace = YES;
    _allowsSendMultiMedia = YES;
    _messageInputViewStyle = XHMessageInputViewStyleFlat;
   
}

- (void)awakeFromNib {
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.inputedText = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
    
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
    _holdDownButton = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        [self setupMessageInputViewBarWithStyle:self.messageInputViewStyle];
    }
}

//#pragma mark - Message input view
//
//- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
//    
//    // 动态改变自身的高度和输入框的高度
//    CGRect prevFrame = self.inputTextView.frame;
//    
//    NSUInteger numLines = MAX([self.inputTextView numberOfLinesOfText],
//                              [self.inputTextView.text numberOfLines]);
//    self.inputTextView.frame = CGRectMake(prevFrame.origin.x,
//                                     prevFrame.origin.y,
//                                     prevFrame.size.width,
//                                     prevFrame.size.height + changeInHeight);
//    
//    CLog(@"改变的高度＝＝＝＝%f=====prevFrame.size.height===%f",changeInHeight,prevFrame.size.height);
//    self.inputTextView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
//                                                  0.0f,
//                                                  (numLines >= 6 ? 4.0f : 0.0f),
//                                                  0.0f);
//    
//    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
//    self.inputTextView.scrollEnabled = YES;
//    
//    if (numLines >= 6) {
//        CGPoint bottomOffset = CGPointMake(0.0f, self.inputTextView.contentSize.height - self.inputTextView.bounds.size.height);
//        [self.inputTextView setContentOffset:bottomOffset animated:YES];
//        [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.text.length - 2, 1)];
//    }
//}
//
+ (CGFloat)textViewLineHeight {
    return 36.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 3.0f : 8.0f;
}

+ (CGFloat)maxHeight {
    
   
    return ([XHMessageInputView maxLines] + 1.0f) * [XHMessageInputView textViewLineHeight];
}

#pragma mark - Text view delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
//    textView.layer.borderColor = [Color(35, 155, 155) CGColor];
//    textView.layer.borderWidth = 1.5f;
//    [textView.layer setMasksToBounds:YES];
//    //设置边框圆角的弧度
//    [textView.layer setCornerRadius:3.0];

    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    self.faceSendButton.selected = NO;
    self.voiceChangeButton.selected = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
   
//    BOOL isSend = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSend"];
//    if (isSend == YES) {
//        self.sendBtn.hidden = YES;
//        self.multiMediaSendButton.hidden = NO;
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isSend"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }

    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
//    textView.layer.borderColor = [[UIColor whiteColor] CGColor];
//    textView.layer.borderWidth = 2.0f;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

      if ([text isEqualToString:@"\n"]) {
        BOOL isSend = [[NSUserDefaults standardUserDefaults] boolForKey:@"isSend"];
          if (isSend == YES) {
//              self.sendBtn.hidden = YES;
              self.multiMediaSendButton.hidden = NO;
              [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isSend"];
               [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"selectSendBtn"];
              [[NSUserDefaults standardUserDefaults] synchronize];
          }

        if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
            [self.delegate didSendTextAction:textView.text];
        }
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length>0) {
        [self.sendBtn setImage:[UIImage imageNamed:@"ico_Send_message"] forState:UIControlStateNormal];
        
    }else{
        [self.sendBtn setImage:[UIImage imageNamed:@"ico_Send_message_cannot"] forState:UIControlStateNormal];
        
    }
}

@end
