//
//  ContentCell.m
//  评论Test
//
//  Created by 伯驹网络 on 2017/11/1.
//  Copyright © 2017年 Nicholas. All rights reserved.
//

#import "ContentCell.h"

@implementation ContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.headerImg.clipsToBounds = YES;
    self.headerImg.layer.cornerRadius = 30.0f;
    
}

//-(void)setDataModel:(hModel *)model
//{
//    [self.headerImg sd_setImageWithURL:[NSURL URLWithString:model.photoURL] placeholderImage:[UIImage imageNamed:PERSON_IMG]];
//    self.nameLab.text = model.user_name;
//    self.contentLab.text = model.info;
//    self.nowDateLab.text = model.nowDate;
//}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
