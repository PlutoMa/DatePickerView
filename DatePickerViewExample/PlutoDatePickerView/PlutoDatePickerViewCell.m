//
//  PlutoDatePickerViewCell.m
//  DatePickerViewExample
//
//  Created by Dareway on 2017/5/24.
//  Copyright © 2017年 Pluto. All rights reserved.
//

#import "PlutoDatePickerViewCell.h"

@interface PlutoDatePickerViewCell ()
@property (nonatomic, strong) UIView *selectedBackView;
@property (nonatomic, strong) UILabel *theLabel;
@property (nonatomic, strong) UILabel *theSubLabel;
@end

@implementation PlutoDatePickerViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.selectedBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height - 6, frame.size.height - 6)];
        self.selectedBackView.center = CGPointMake(frame.size.width / 2.0, (frame.size.height - 6) / 2.0);
        self.selectedBackView.layer.cornerRadius = self.selectedBackView.frame.size.height / 2.0;
        self.selectedBackView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.selectedBackView];
        self.theLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, (frame.size.height - 6) / 3.0 * 2)];
        self.theLabel.textAlignment = NSTextAlignmentCenter;
        self.theLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightThin];
        [self.contentView addSubview:self.theLabel];
        self.theSubLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.theLabel.frame.origin.y + self.theLabel.frame.size.height - 5, self.theLabel.frame.size.width, self.theLabel.frame.size.height / 2.0)];
        self.theSubLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.theSubLabel.textAlignment = NSTextAlignmentCenter;
        self.theSubLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightThin];
        [self.contentView addSubview:self.theSubLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title subTitle:(NSString *)subTitle isWeekend:(BOOL)isWeekend isSelected:(BOOL)isSelected isGray:(BOOL)isGray {
    self.theLabel.text = title;
    self.theSubLabel.text = subTitle;
    if (isWeekend) {
        if (isSelected) {
            self.selectedBackView.hidden = NO;
            self.selectedBackView.backgroundColor = [UIColor colorWithRed:254.0 / 255.0 green:86.0 / 255.0 blue:83.0 / 255.0 alpha:1.0];
            self.theLabel.textColor = [UIColor whiteColor];
            self.theSubLabel.textColor = self.theLabel.textColor;
        } else {
            self.selectedBackView.hidden = YES;
            self.theLabel.textColor = [UIColor colorWithRed:254.0 / 255.0 green:86.0 / 255.0 blue:83.0 / 255.0 alpha:1.0];
            self.theSubLabel.textColor = self.theLabel.textColor;
        }
    } else {
        if (isSelected) {
            self.selectedBackView.hidden = NO;
            self.selectedBackView.backgroundColor = [UIColor colorWithRed:87.0 / 255.0 green:126.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
            self.theLabel.textColor = [UIColor whiteColor];
            self.theSubLabel.textColor = self.theLabel.textColor;
        } else {
            self.selectedBackView.hidden = YES;
            self.theLabel.textColor = [UIColor blackColor];
            self.theSubLabel.textColor = self.theLabel.textColor;
        }
    }
    if (isGray) {
        self.selectedBackView.backgroundColor = [UIColor colorWithRed:236.0 / 255.0 green:236.0 / 255.0 blue:236.0 / 255.0 alpha:1.0];
        self.theLabel.textColor = [UIColor colorWithRed:184.0 / 255.0 green:184.0 / 255.0 blue:184.0 / 255.0 alpha:1.0];
        self.theSubLabel.textColor = self.theLabel.textColor;
    }
}

@end

