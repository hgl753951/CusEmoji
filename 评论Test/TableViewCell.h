//
//  TableViewCell.h
//  评论Test
//
//  Created by 伯驹网络 on 2017/11/1.
//  Copyright © 2017年 Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *headerLab;
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@end
