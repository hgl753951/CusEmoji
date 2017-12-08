//
//  hMyDetailViewController.m
//  评论Test
//
//  Created by 伯驹网络 on 2017/11/30.
//  Copyright © 2017年 Nicholas. All rights reserved.
//

#import "hMyDetailViewController.h"
#import "Masonry.h"
#import "ContentCell.h"
#import "hModel.h"

@interface hMyDetailViewController ()
@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)UIView *headerView;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)NSDictionary *dict;

@property (nonatomic, weak, readwrite) XHEmotionManagerView *emotionManagerView;
@property (nonatomic, assign) CGFloat keyboardViewHeight;

@end

@implementation hMyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _dataArray = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"详情";
    _dict =  @{
               @"photoURL":@"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2077447965,2640702927&fm=27&gp=0.jpg",
               @"user_name":@"李三",
               @"info":@"北国风光，千里冰封，万里雪飘。望长城内外，惟余莽莽；大河上下，顿失滔滔。山舞银蛇，原驰蜡象，欲与天公试比高。须晴日，看红装素裹，分外妖娆。江山如此多娇，引无数英雄竞折腰。 惜秦皇汉武，略输文采；唐宗宋祖，稍逊风骚。 一代天骄，成吉思汗，只识弯弓射大雕。 俱往矣，数风流人物，还看今朝。",
               @"nowDate":@"1485163320"
               };
    
    self.keyboardViewHeight = (kXHEmotionImageViewSize+15)*3+kXHEmotionPageControlHeight+10;
    //增加监听，当键改变时时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification    object:nil];
    
    NSString *emotionPath = [[NSBundle mainBundle] pathForResource:@"emotion" ofType:@"plist"];
    NSString *emotionImagePath = [[NSBundle mainBundle] pathForResource:@"emotionImage1" ofType:@"plist"];
    self.facesDic = [[NSDictionary alloc]initWithContentsOfFile:emotionImagePath];
    self.faceNUmArr = [[NSArray alloc]initWithContentsOfFile:emotionPath];
    
    NSMutableArray *lastArr = [[NSMutableArray alloc]initWithCapacity:0];
    for (NSNumber  *str in self.faceNUmArr) {
        int aaa = [str intValue];
        int sym = EMOJI_CODE_TO_SYMBOL(aaa);
        NSString *emoT = [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
        [lastArr addObject:emoT];
    }
    self.facesAry = lastArr;
    
    [self initInputView];
}

-(void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    [UIView animateWithDuration:0.1 animations:^{
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = MainScreen_height-NavigationHeight-50-height;
        self.tableView.frame = tableFrame;
        CGRect rect = self.inputView.frame;
        rect.origin.y = MainScreen_height-height-50;
        self.inputView.frame = rect;
    }];
}

-(void)keyboardWillHide:(NSNotification *)aNotification
{
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = MainScreen_height-NavigationHeight-50;
    self.tableView.frame = tableFrame;
    
    CGRect rect = self.inputView.frame;
    rect.origin.y = MainScreen_height-45;
    self.inputView.frame = rect;
}

-(void)initInputView
{
    
    
    // 设置Message TableView 的bottom edg
    
    CGFloat inputViewHeight = KEYBOARD_height;
    // 输入工具条的frame
    CGRect inputFrame = CGRectMake(0.0f,
                                   self.view.frame.size.height - inputViewHeight,
                                   self.view.frame.size.width,
                                   inputViewHeight);
    // 初始化输入工具条
    XHMessageInputView *inputView = [[XHMessageInputView alloc] initWithFrame:inputFrame];
    inputView.allowsSendFace = YES;
    inputView.allowsSendVoice = NO;
    inputView.allowsSendMultiMedia = NO;
    inputView.delegate = self;
    [self.view addSubview:inputView];
    [self.view bringSubviewToFront:inputView];
    _inputView = inputView;
    
    self.inputView.backgroundColor = Color(248, 248, 248);
    
    NSMutableArray *emotionManagers = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i ++) {
        XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
        emotionManager.emotionName = nil;
        NSMutableArray *emotions = [NSMutableArray array];
        for (NSInteger j = 0; j < self.facesAry.count; j ++) {
            XHEmotion *emotion = [[XHEmotion alloc] init];
            NSString * tmpStr = [self.facesAry objectAtIndex:j];
            emotion.emotionStr = tmpStr;
            if (j==20) {
                emotion.emotionStr = @"";
            }
            if (j==41) {
                emotion.emotionStr = @"";
            }
            if (j==62) {
                emotion.emotionStr = @"";
            }
            if (j==83) {
                emotion.emotionStr = @"";
            }
            if (j==94) {
                emotion.emotionStr = @"";
            }
            [emotions addObject:emotion];
        }
        emotionManager.emotions = emotions;
        [emotionManagers addObject:emotionManager];
    }
    self.emotionManagers = emotionManagers;
    [self.emotionManagerView reloadData];
    
    [self createView];
    [self creatWebView];
}

- (XHEmotionManagerView *)emotionManagerView {
    
    if (!_emotionManagerView) {
        XHEmotionManagerView *emotionManagerView = [[XHEmotionManagerView alloc] initWithFrame:CGRectMake(0, MainScreen_height, MainScreen_width, self.keyboardViewHeight)];
        emotionManagerView.delegate = self;
        emotionManagerView.dataSource = self;
        emotionManagerView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        emotionManagerView.alpha = 1.0;
        [self.view addSubview:emotionManagerView];
        _emotionManagerView = emotionManagerView;
    }
    
    [self.view bringSubviewToFront:_emotionManagerView];
    return _emotionManagerView;
}



-(void)creatWebView
{
    self.webView = [UIWebView new];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.delegate = self;
    self.webView.userInteractionEnabled = NO;
    self.webView.scrollView.scrollEnabled = NO;
    NSLog(@"html====%@",[[self dataArray] valueForKey:@"info"]);
    NSString *title=@"韩寒《后会无期》奇葩的吸金3秘籍";
    
    NSString *linkStr=[NSString stringWithFormat:@"<a href='%@'>我的博客</a> <a href='%@'>原文</a>",@"http://blog.csdn.net/wildcatlele",@"http://jincuodao.baijia.baidu.com/article/26059"];
    
    NSString *p1=@"韩寒《后会无期》的吸金能力很让我惊讶！8月12日影片票房已成功冲破6亿大关。而且排片量仍保持10 以上，以日收千万的速度稳步向七亿进军。";
    
    NSString *p2=@"要知道，《后会无期》不是主流类型片，是一个文艺片。不像《小时代》，是一个商业主流的偶像电影。";
    
    NSString *image2=[NSString stringWithFormat:@"<img src='%@'  height='280' width='375' />",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509537524520&di=8c2dc517fd7e80ca11a541b52b99fa75&imgtype=0&src=http%3A%2F%2Fpic42.nipic.com%2F20140606%2F18939690_111450345176_2.jpg"];
    
    NSString *image3=[NSString stringWithFormat:@"<img src='%@'  height='280' width='375' />",@""];
    
    NSString *image4=[NSString stringWithFormat:@"<img src='%@'  height='280' width='375' />",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509537524520&di=8c2dc517fd7e80ca11a541b52b99fa75&imgtype=0&src=http%3A%2F%2Fpic42.nipic.com%2F20140606%2F18939690_111450345176_2.jpg"];
    
    NSString *image5=[NSString stringWithFormat:@"<img src='%@'  height='280' width='375' />",@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1509537524520&di=8c2dc517fd7e80ca11a541b52b99fa75&imgtype=0&src=http%3A%2F%2Fpic42.nipic.com%2F20140606%2F18939690_111450345176_2.jpg"];
    
    NSString *p3=@"太奇葩了！有人说，这是中国电影市场的红利，是粉丝电影的成功。但是，有一部投资3000万的粉丝电影《我就是我》，有明星，制作也不错，基本上是惨败。";
    
    NSString *p4=@"《后会无期》卖的不是好故事，是优越感。特别是针对80、90后的人群，你有没有发现，看《后会无期》比看《小时代3》有明显的优越感。故事虽然一般，但是很多人看完后，会在微博、微信上晒照片。所以说，对一个族群靠的不是广度，而是深度。<br>\
    \
    很凶残，值得大家借鉴。韩寒《后会无期》还有什么秘密武器，欢迎《后会无期》团队或相关方爆料，直接留言即可，有料的可以送黎万强亲笔签名的《参与感》一书。";
    //初始化和html字符串
    NSString *htmlURlStr=[NSString stringWithFormat:@"<body style='background-color:#EBEBF3'><h2>%@</h2><p>%@</p> <p>%@ </p> <br><p> %@</p> <p>%@</p>%@<p>%@%@%@%@</p></body>",title,linkStr,p1,p2,p3,image2,image3,image4,image5,p4];
    [self.webView loadHTMLString:htmlURlStr baseURL:nil];
    
    [_headerView addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(@0);
        make.height.equalTo(@50);
    }];
}

-(void)createView
{
    _headerView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth, 1)];
    _headerView.alpha=0;
    _headerView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_headerView];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize actualSize = [webView sizeThatFits:CGSizeZero];
    CGRect newFarme = webView.frame;
    newFarme.size.height = actualSize.height;
    NSLog(@"ssssss==%f",newFarme.size.height);
    [self.webView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(newFarme.size.height));
    }];
    
    _headerView.frame = CGRectMake(0, 0, kWidth, newFarme.size.height);
    NSLog(@"HEAD======%f",_headerView.bounds.size.height);
    _headerView.alpha = 1;
    [self creatTableView];
}

-(void)creatTableView
{
    self.tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 64, kWidth, self.view.bounds.size.height-70-44) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView=_headerView;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.estimatedRowHeight = 300;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"ContentCell" bundle:nil] forCellReuseIdentifier:@"ContentCell"];
    [self.view addSubview:self.tableView];
}

-(void)sendMessage:(NSString *)text
{
    hModel *model = [[hModel alloc] init];
    model.message =_inputView.inputTextView.text;
    
    if (model.message != nil && [model.message isEqualToString:@""]) {
        [UIAlertView bk_showAlertViewWithTitle:@"温馨提醒" message:@"输入不能为空" cancelButtonTitle:@"取消" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
    }else
    {
//        [_tf resignFirstResponder];
        [_dataArray addObject:model];
        NSLog(@"--%@",_dataArray);
        [_tableView reloadData];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArray.count-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];//键盘下落
        self.inputView.inputTextView.text = @"";
        [self.inputView.sendBtn setImage:[UIImage imageNamed:@"ico_Send_message_cannot"] forState:UIControlStateNormal];
        self.tableView.frame = CGRectMake(0, NavigationHeight, MainScreen_width, MainScreen_height-50.0f-NavigationHeight);
        self.textViewInputViewType = XHInputViewTypeEmotion;
        [self layoutOtherMenuViewHiden:YES];//表情键盘下落
    }
    
}

#pragma mark - XHEmotionManagerView DataSource

- (NSInteger)numberOfEmotionManagers {
    return self.emotionManagers.count;
}

- (XHEmotionManager *)emotionManagerForColumn:(NSInteger)column {
    return [self.emotionManagers objectAtIndex:column];
}

- (NSArray *)emotionManagersAtManager {
    return self.emotionManagers;
}

#pragma mark - XHMessageInputView Delegate

- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView {
    
    self.textViewInputViewType = XHInputViewTypeText;
}

- (void)inputTextViewDidBeginEditing:(XHMessageTextView *)messageInputTextView {
    
}
- (void)didSendTextAction:(NSString *)text {
    
    [self sendMessage:text];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}

#pragma mark - XHEmotionManagerView Delegate

- (void)didSelecteEmotion:(XHEmotion *)emotion atIndexPath:(NSIndexPath *)indexPath {
    //    self.inputStr = self.inputView;
    NSString *newStr;
    if (indexPath.row == 20||indexPath.row==41||indexPath.row==62||indexPath.row==83) {
        if (self.inputView.inputTextView.text.length>1) {
            CLog(@"===isEqualToString:]====%lu",(unsigned long)self.inputView.inputTextView.text.length);
            if ([self.facesAry containsObject:[self.inputView.inputTextView.text substringFromIndex:self.inputView.inputTextView.text.length-2]]) {
                CLog(@"删除emoji %@",[self.inputView.inputTextView.text substringFromIndex:self.inputView.inputTextView.text.length-2]);
                
                newStr=[self.inputView.inputTextView.text substringToIndex:self.inputView.inputTextView.text.length-2];
            }else{
                CLog(@"删除文字%@",[self.inputView.inputTextView.text substringFromIndex:self.inputView.inputTextView.text.length-1]);
                newStr=[self.inputView.inputTextView.text substringToIndex:self.inputView.inputTextView.text.length-1];
            }
            self.inputView.inputTextView.text=newStr;
        }else{
            newStr=@"";
            self.inputView.inputTextView.text = newStr;
        }
        
    }else{
        NSString *faceNumStr = [self.faceNUmArr objectAtIndex:indexPath.row];
        NSArray *allKeys = [self.facesDic allKeysForObject:faceNumStr];
        NSString *faceStr = [self.facesAry objectAtIndex:indexPath.row];
        if ([allKeys count]>0) {
            NSString *valueStr = [allKeys objectAtIndex:0];
            [self didSendEmotionMessageWithEmotionPath:faceStr faceStr:valueStr];
        }
    }
    
}

- (NSString *)checkTheChatStringReplaceFace:(NSString *)theString
{
    NSArray * arr = [theString componentsSeparatedByString:@"["];
    for (int i= 0; i<[arr count]; i++) {
        NSRange range=[theString rangeOfString:@"["];
        NSRange range1=[theString rangeOfString:@"]"];
        //判断当前字符串是否还有表情的标志。
        if (range.length>0 && range1.length>0) {
            
            NSString * strTmp = [theString substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            NSString * valueStr = [self.facesDic objectForKey:strTmp];
            int aaa = [valueStr intValue];
            int sym = EMOJI_CODE_TO_SYMBOL(aaa);
            NSString *emoT = [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
            theString = [theString stringByReplacingOccurrencesOfString:strTmp withString:emoT];
        }
        
    }
    
    return theString;
}
- (void)didSendEmotionMessageWithEmotionPath:(NSString *)emotionPath faceStr:(NSString *)str {
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isSend"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"selectSendBtn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.inputView.sendBtn setImage:[UIImage imageNamed:@"ico_Send_message"] forState:UIControlStateNormal];
    
    self.inputView.multiMediaSendButton.hidden = YES;
    self.inputView.sendBtn.hidden = NO;
    self.inputView.inputTextView.text = [self.inputView.inputTextView.text stringByAppendingString:emotionPath];
    
    DLog(@"send emotionPath:%@", self.inputView.inputTextView.text);
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    //    self.isUserScrolling = YES;
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
    self.textViewInputViewType = XHInputViewTypeEmotion;
    [self layoutOtherMenuViewHiden:YES];
    
    
    //    if (self.textViewInputViewType != XHInputViewTypeNormal && self.textViewInputViewType != XHInputViewTypeText) {
    //        [self layoutOtherMenuViewHiden:YES];
    //    }
}
- (void)didSendFaceAction:(BOOL)sendFace {
    if (sendFace) {
        self.textViewInputViewType = XHInputViewTypeEmotion;
        [self layoutOtherMenuViewHiden:NO];
    } else {
        
        self.textViewInputViewType = XHInputViewTypeEmotion;
        [self layoutOtherMenuViewHiden:YES];
        
    }
}

#pragma mark - Other Menu View Frame Helper Mehtod

- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    
    NSLog(@"%@",hide?@"YES":@"NO");
    
    [self.inputView.inputTextView resignFirstResponder];
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        __block CGRect otherMenuViewFrame;
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            if (hide) {
                self.inputView.frame = CGRectMake(0, MainScreen_height-50.0f, MainScreen_width, 50);
                [self.view bringSubviewToFront:self.inputView];
                
            }else{
                [self.view bringSubviewToFront:self.inputView];
                CGRect rect = self.inputView.frame;
                rect.origin.y = MainScreen_height-self.keyboardViewHeight-50.0;
                self.inputView.frame = rect;
            }
        };
        
        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.emotionManagerView.frame;
            
            otherMenuViewFrame.origin.y = (hide ? MainScreen_height : (MainScreen_height - CGRectGetHeight(otherMenuViewFrame)));
            self.emotionManagerView.frame = otherMenuViewFrame;
            self.emotionManagerView.alpha = !hide;
            
        };
        if (hide) {
            switch (self.textViewInputViewType) {
                case XHInputViewTypeEmotion: {
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeShareMenu: {
                    break;
                }
                default:
                    break;
            }
            
            
        } else {
            
            // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
            switch (self.textViewInputViewType) {
                case XHInputViewTypeEmotion: {
                    // 1、先隐藏和自己无关的View
                    //                    ShareMenuViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeShareMenu: {
                    // 1、先隐藏和自己无关的View
                    EmotionManagerViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    //                    ShareMenuViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        }
        InputViewAnimation(hide);
    } completion:^(BOOL finished) {
        NSLog(@"我走了没有");
    }];
}


//-(void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    if (scrollView.contentOffset.y > 0) {
//        //展示
//        self.inputView.frame = CGRectMake(0, kHeight - 60, kWidth, 60);
//        self.tableView.frame = CGRectMake(0, 64, kWidth, self.view.bounds.size.height-70-44);
//        self.navigationController.navigationBarHidden = NO;
//        [_tf resignFirstResponder];
//    }else
//    {
//        //隐藏
//        self.inputView.frame = CGRectMake(0, kHeight, kWidth, 60);
//        self.tableView.frame = CGRectMake(0, 64, kWidth, self.view.bounds.size.height);
//        self.navigationController.navigationBarHidden = YES;
//        [_tf resignFirstResponder];
//    }
//}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContentCell"];
    if (!cell) {
        cell = [[ContentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContentCell"];
    }
    
    [cell.headerImg sd_setImageWithURL:[NSURL URLWithString:[_dict objectForKey:@"photoURL"]] placeholderImage:[UIImage imageNamed:PERSON_IMG]];
    cell.nameLab.text = [_dict objectForKey:@"user_name"];
    //    cell.contentLab.text = [_dict objectForKey:@"info"];
    cell.nowDateLab.text = [_dict objectForKey:@"nowDate"];
    hModel *model = _dataArray[indexPath.row];
    cell.contentLab.text = model.message;
    return cell;
}

//-(BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [_tf resignFirstResponder];
//    return YES;
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
