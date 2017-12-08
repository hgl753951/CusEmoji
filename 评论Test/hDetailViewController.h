//
//  hDetailViewController.h
//  评论Test
//
//  Created by 伯驹网络 on 2017/11/1.
//  Copyright © 2017年 Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface hDetailViewController : UIViewController<UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property(strong,nonatomic)NSString *idenStr;

@end
