//
//  hDetailViewController.m
//  评论Test
//
//  Created by 伯驹网络 on 2017/11/1.
//  Copyright © 2017年 Nicholas. All rights reserved.
//

#import "hDetailViewController.h"
#import "ContentCell.h"
#import "hModel.h"
//#import "XHEmotionManagerView.h"

@interface hDetailViewController ()<UITextFieldDelegate>

@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,strong)UITextField *tf;
@property (nonatomic,strong)UIView *inputView;
@property (nonatomic,strong)UIWebView *webView;
@property (nonatomic,strong)UIView *headerView;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)NSDictionary *dict;

//@property (nonatomic, weak, readwrite) XHEmotionManagerView *emotionManagerView;
@property (nonatomic, assign) CGFloat keyboardViewHeight;

@end

@implementation hDetailViewController

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
        tableFrame.size.height = kHeight-NavigationHeight-60-height;
        self.tableView.frame = tableFrame;
        CGRect rect = self.inputView.frame;
        rect.origin.y = kHeight-height-60;
        self.inputView.frame = rect;
    }];
}

-(void)keyboardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.1 animations:^{
        
        CGRect tableFrame = self.tableView.frame;
        tableFrame.size.height = kHeight-NavigationHeight-60;
        self.tableView.frame = tableFrame;
        
        CGRect rect = self.inputView.frame;
        rect.origin.y = kHeight-60;
        self.inputView.frame = rect;
    }];
}

-(void)initInputView
{
    [self createView];
    [self creatWebView];

    _inputView = [[UIView alloc]initWithFrame:CGRectMake(0, kHeight, kWidth, 60)];
    _inputView.backgroundColor = RGBAColor(159, 159, 159, 1);
    
    [self.view addSubview:_inputView];
    
    _tf = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, kWidth - 60, 40)];
    _tf.delegate = self;
    _tf.returnKeyType = UIReturnKeyDefault;
    [_inputView addSubview:_tf];
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBtn.frame = CGRectMake(kWidth - 50-5, 3, kWidth - _tf.frame.size.width, 50);
    [_rightBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_inputView addSubview:_rightBtn];
    
    //增加监听，当键改变时时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification    object:nil];
}

-(void)btnClick:(id)sender
{
    hModel *model = [[hModel alloc] init];
    model.message = _tf.text;
    
    if (model.message != nil && [model.message isEqualToString:@""]) {
        [UIAlertView bk_showAlertViewWithTitle:@"温馨提醒" message:@"输入不能为空" cancelButtonTitle:@"取消" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
    }else
    {
        [_tf resignFirstResponder];
        [_dataArray addObject:model];
        NSLog(@"--%@",_dataArray);
        [_tableView reloadData];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_dataArray.count-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        _tf.text = nil;
    }
    
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
    self.tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 64, kWidth, self.view.bounds.size.height) style:UITableViewStylePlain];
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > 0) {
        //展示
        self.inputView.frame = CGRectMake(0, kHeight - 60, kWidth, 60);
        self.tableView.frame = CGRectMake(0, 64, kWidth, self.view.bounds.size.height-70-44);
        self.navigationController.navigationBarHidden = NO;
        [_tf resignFirstResponder];
    }else
    {
        //隐藏
        self.inputView.frame = CGRectMake(0, kHeight, kWidth, 60);
        self.tableView.frame = CGRectMake(0, 64, kWidth, self.view.bounds.size.height);
        self.navigationController.navigationBarHidden = YES;
        [_tf resignFirstResponder];
    }
}

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

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_tf resignFirstResponder];
    return YES;
}

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
