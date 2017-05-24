//
//  PlutoDatePickerView.h
//  DatePickerViewExample
//
//  Created by Pluto on 2017/5/24.
//  Copyright © 2017年 Pluto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlutoDPVModel : NSObject
///年份
@property (nonatomic, assign) NSInteger year;
///月份
@property (nonatomic, assign) NSInteger month;
///日
@property (nonatomic, assign) NSInteger day;
///星期几
@property (nonatomic, assign) NSInteger weekDay;
@end

@class PlutoDatePickerView;

@protocol PlutoDatePickerViewDelegate <NSObject>
- (void)pickerView:(PlutoDatePickerView *)pickerView didSelectTime:(PlutoDPVModel *)time;
@end

@interface PlutoDatePickerView : UIView
@property (nonatomic, assign) BOOL isSetDate;
@property (nonatomic, weak) id<PlutoDatePickerViewDelegate> delegate;
///初始化
- (instancetype)initWithFrame:(CGRect)frame delegate:(id<PlutoDatePickerViewDelegate>)delegate;
///设置新的时间
- (void)setCurrentDate:(NSDate *)date;

@end
