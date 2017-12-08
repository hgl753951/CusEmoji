//
//  ContentCell.h
//  评论Test
//
//  Created by 伯驹网络 on 2017/11/1.
//  Copyright © 2017年 Nicholas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hModel.h"

@interface ContentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headerImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UILabel *nowDateLab;

//-(void)setDataModel:(hModel *)model;

@end
