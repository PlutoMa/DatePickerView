//
//  PlutoDatePickerView.m
//  DatePickerViewExample
//
//  Created by Pluto on 2017/5/24.
//  Copyright © 2017年 Pluto. All rights reserved.
//

#import "DWScheduleDatePickerView.h"
#import "DWScheduleDatePickerViewCell.h"
#import "DWScheduleDatePickerLayout.h"

@implementation DWScheduleDPVModel
@end

@interface DWScheduleDatePickerView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    CGFloat monthOffset;
    NSInteger moveType;
}

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UICollectionView *weekCollectionView;
@property (nonatomic, strong) UICollectionView *monthCollectionView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
///当前选择时间
@property (nonatomic, strong) DWScheduleDPVModel *selectedDate;
///周选择当前周日
@property (nonatomic, strong) DWScheduleDPVModel *weekStartDay;
///周选择当前周六
@property (nonatomic, strong) DWScheduleDPVModel *weekEndDay;
///月选择当前月（默认1号）
@property (nonatomic, strong) DWScheduleDPVModel *monthStartDay;
///当前时间数组
@property (nonatomic, strong) NSMutableArray<DWScheduleDPVModel *> *currentWeekDateArray;
@property (nonatomic, strong) NSMutableArray<DWScheduleDPVModel *> *currentMonthDateArray;
@end

@implementation DWScheduleDatePickerView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<DWSchedulePickerViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        //布局
        [self setupUI];
        
        //添加手势
        UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGRAction:)];
        [self addGestureRecognizer:panGR];
        
        //设置时间
        self.isSetDate = NO;
    }
    return self;
}

- (void)setSelectedDate:(DWScheduleDPVModel *)selectedDate {
    if (selectedDate.year != self.selectedDate.year || selectedDate.month != self.selectedDate.month || selectedDate.day != self.selectedDate.day) {
        _selectedDate = selectedDate;
        [self.weekCollectionView reloadData];
        [self.monthCollectionView reloadData];
        if (self.delegate && [self.delegate respondsToSelector:@selector(pickerView:didSelectTime:)]) {
            [self.delegate pickerView:self didSelectTime:self.selectedDate];
        }
    }
}

#pragma mark - 滑动事件

///滑动手势事件
- (void)panGRAction:(UIPanGestureRecognizer *)gr {
    //当偏移量大于10的时候才生效，避免产生误滑
    CGFloat offset = [gr translationInView:self].y;
    if (offset > 10) {
        if (self.weekCollectionView.hidden == NO && self.monthCollectionView.hidden == YES) {
            moveType = 1;
            [self calCurrentMonthStartDay];
            [self calMonthDateArray];
            self.weekCollectionView.hidden = YES;
            self.monthCollectionView.hidden = NO;
            if (self.weekStartDay.month != self.monthStartDay.month) {
                monthOffset = 1.0f;
            } else {
                for (int i = (int)self.currentMonthDateArray.count / 3; i < (int)self.currentMonthDateArray.count / 3 * 2; i = i + 7) {
                    DWScheduleDPVModel *model = [self.currentMonthDateArray objectAtIndex:i];
                    if (model.year == self.weekStartDay.year && model.month == self.weekStartDay.month && model.day == self.weekStartDay.day) {
                        monthOffset = 40.0 * (i - self.currentMonthDateArray.count / 3) / 7;
                        break;
                    }
                }
                monthOffset = monthOffset > 0 ? monthOffset : 1.0f;
            }
        } else if (self.weekCollectionView.hidden == YES && self.monthCollectionView.hidden == NO) {
            if (self.plt_height < 70 + self.monthCollectionView.plt_height) {
                CGFloat changeY = -monthOffset + offset - 10;
                CGFloat changeHeight = monthOffset;
                if (monthOffset < 40) {
                    changeY = 0;
                    changeHeight = self.monthCollectionView.plt_height;
                }
                self.monthCollectionView.frame = CGRectMake(self.monthCollectionView.plt_x, 70 + changeY, self.monthCollectionView.plt_width, self.monthCollectionView.plt_height);
                self.frame = CGRectMake(self.plt_x, self.plt_y, self.plt_width, 110 + ((offset - 10) / changeHeight) * (self.monthCollectionView.plt_height - 40));
            } else {
                self.monthCollectionView.frame = CGRectMake(self.monthCollectionView.plt_x, 70, self.monthCollectionView.plt_width, self.monthCollectionView.plt_height);
                self.frame = CGRectMake(self.plt_x, self.plt_y, self.plt_width, self.monthCollectionView.plt_height + 70);
            }
        }
    } else if (offset < -10) {
        if (self.weekCollectionView.hidden == YES && self.monthCollectionView.hidden == NO) {
            if (monthOffset < 0) {
                moveType = 2;
                monthOffset = 1.0;
                [self calCurrentWeekDay];
                [self calWeekDateArray];
            }
            if (self.plt_height > 110) {
                CGFloat changeY = offset + 10;
                CGFloat changeHeight = monthOffset;
                if (monthOffset < 40) {
                    changeY = 0;
                    changeHeight = self.monthCollectionView.plt_height;
                }
                self.monthCollectionView.frame = CGRectMake(self.monthCollectionView.plt_x, 70 + changeY, self.monthCollectionView.plt_width, self.monthCollectionView.plt_height);
                self.frame = CGRectMake(self.plt_x, self.plt_y, self.plt_width, 70 + self.monthCollectionView.plt_height - ((-offset - 10) / changeHeight) * (self.monthCollectionView.plt_height - 40));
            } else {
                self.weekCollectionView.hidden = NO;
                self.monthCollectionView.hidden = YES;
                self.frame = CGRectMake(self.plt_x, self.plt_y, self.plt_width, 110);
            }
        }
    }
    if (gr.state == UIGestureRecognizerStateEnded || gr.state == UIGestureRecognizerStateFailed || gr.state == UIGestureRecognizerStateCancelled) {
        if (moveType == 1) {
            [UIView animateWithDuration:0.2 animations:^{
                self.monthCollectionView.frame = CGRectMake(self.monthCollectionView.plt_x, 70, self.monthCollectionView.plt_width, self.monthCollectionView.plt_height);
                self.frame = CGRectMake(self.plt_x, self.plt_y, self.plt_width, self.monthCollectionView.plt_height + 70);
            }];
            self.weekCollectionView.hidden = YES;
            self.monthCollectionView.hidden = NO;
        } else if (moveType == 2) {
            [UIView animateWithDuration:0.2 animations:^{
                self.frame = CGRectMake(self.plt_x, self.plt_y, self.plt_width, 110);
                self.monthCollectionView.frame = CGRectMake(self.monthCollectionView.plt_x, 70 - monthOffset, self.monthCollectionView.plt_width, self.monthCollectionView.plt_height);
            } completion:^(BOOL finished) {
                self.weekCollectionView.hidden = NO;
                self.monthCollectionView.hidden = YES;
            }];
        }
        monthOffset = -100;
        moveType = 0;
    }
    if (fabs(offset) > 10) {
        [self calCurrentMonthStartDay];
        self.topLabel.text = [NSString stringWithFormat:@"%ld-%02ld", (long)self.monthStartDay.year, (long)self.monthStartDay.month];
    }
}



//设置新的时间
- (void)setCurrentDate:(NSDate *)date {
    self.isSetDate = YES;
    self.selectedDate = [self getModelWithDate:date];
    self.weekStartDay = [self getModelWithDate:[NSDate dateWithTimeInterval:-self.selectedDate.weekDay * 24 * 60 * 60 sinceDate:[self getDateWithModel:self.selectedDate]]];
    self.weekEndDay = [self getModelWithDate:[NSDate dateWithTimeInterval:(6 - self.selectedDate.weekDay) * 24 * 60 * 60 sinceDate:[self getDateWithModel:self.selectedDate]]];
    [self calWeekDateArray];
    [self calCurrentMonthStartDay];
    self.topLabel.text = [NSString stringWithFormat:@"%ld-%02ld", (long)self.monthStartDay.year, (long)self.monthStartDay.month];
}

///计算需要的周时间数组
- (void)calWeekDateArray {
    
    [self.currentWeekDateArray removeAllObjects];
    for (int i = 0; i < 21; i++) {
        NSDate *todayDate;
        if (i < 7) {
            todayDate = [NSDate dateWithTimeInterval:- 24 * 60 * 60 * (7 - i) sinceDate:[self getDateWithModel:self.weekStartDay]];
        } else if (i > 13) {
            todayDate = [NSDate dateWithTimeInterval:24 * 60 * 60 * (i - 13) sinceDate:[self getDateWithModel:self.weekEndDay]];
        } else {
            todayDate = [NSDate dateWithTimeInterval:24 * 60 * 60 * (i - 7) sinceDate:[self getDateWithModel:self.weekStartDay]];
        }
        NSString *dateStr = [self.dateFormatter stringFromDate:todayDate];
        DWScheduleDPVModel *model = [[DWScheduleDPVModel alloc] init];
        model.year = [[dateStr substringToIndex:4] integerValue];
        model.month = [[dateStr substringWithRange:NSMakeRange(4, 2)] integerValue];
        model.day = [[dateStr substringFromIndex:dateStr.length - 2] integerValue];
        model.weekDay = (i + 7) % 7;
        [self.currentWeekDateArray addObject:model];
    }
    [self.weekCollectionView reloadData];
    [self.weekCollectionView setContentOffset:CGPointMake(self.weekCollectionView.plt_width, 0)];
}

///计算需要的月时间数组
- (void)calMonthDateArray {
    //得到当月第一天
    NSDate *showPageDate = [self getDateWithModel:self.monthStartDay];
    //得到偏移
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSWeekdayCalendarUnit fromDate:showPageDate];
    NSInteger weekDay = [comp weekday];
    NSInteger currentPageDay = [[[self.dateFormatter stringFromDate:showPageDate] substringFromIndex:6] integerValue];
    NSInteger offset = weekDay - currentPageDay % 7;
    //得到当月天数
    NSRange range = [calendar rangeOfUnit: NSDayCalendarUnit
                                   inUnit: NSMonthCalendarUnit
                                  forDate: showPageDate];
    NSInteger dayÇount = range.length;
    //得到当月周数
    NSInteger weekCount = (offset + dayÇount) / 7;
    if ((offset + dayÇount) % 7 != 0) {
        weekCount = weekCount + 1;
    }
    self.monthCollectionView.frame = CGRectMake(self.monthCollectionView.plt_x, self.monthCollectionView.plt_y, self.monthCollectionView.plt_width, 40 * weekCount);
    if (self.weekCollectionView.hidden == YES && self.monthCollectionView.hidden == NO) {
        self.frame = CGRectMake(self.plt_x, self.plt_y, self.plt_width, 70 + 40 * weekCount);
    }
    //得到要显示的天数
    NSInteger showDayCount = 7 * weekCount;
    
    [self.currentMonthDateArray removeAllObjects];
    [self.currentMonthDateArray addObjectsFromArray:[self getMonthDayWithMonth:[self lastMonth] count:showDayCount]];
    [self.currentMonthDateArray addObjectsFromArray:[self getMonthDayWithMonth:self.monthStartDay count:showDayCount]];
    [self.currentMonthDateArray addObjectsFromArray:[self getMonthDayWithMonth:[self nextMonth] count:showDayCount]];
    [self.monthCollectionView reloadData];
    [self.monthCollectionView setContentOffset:CGPointMake(self.monthCollectionView.plt_width, 0)];
}

///根据月份 获取一月天
- (NSArray<DWScheduleDPVModel *> *)getMonthDayWithMonth:(DWScheduleDPVModel *)model count:(NSInteger)count {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    NSDate *date = [self getDateWithModel:model];
    for (int i = 0; i < count; i++) {
        NSDate *todayDate = [NSDate dateWithTimeInterval:(i - model.weekDay) * 24 * 60 * 60 sinceDate:date];
        DWScheduleDPVModel *temp = [self getModelWithDate:todayDate];
        [array addObject:temp];
    }
    return [array copy];
}


#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.weekCollectionView == collectionView) {
        return self.currentWeekDateArray.count;
    } else if (self.monthCollectionView == collectionView) {
        return self.currentMonthDateArray.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DWScheduleDatePickerViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DWScheduleDatePickerViewCell plt_cellReuseIdentifier] forIndexPath:indexPath];
    DWScheduleDPVModel *model;
    if (self.weekCollectionView == collectionView) {
        model = [self.currentWeekDateArray objectAtIndex:indexPath.row];
    } else if (self.monthCollectionView == collectionView) {
        model = [self.currentMonthDateArray objectAtIndex:indexPath.row];
    }
    BOOL isWeekend = model.weekDay == 0 || model.weekDay == 6;
    BOOL isSelected = model.year == self.selectedDate.year && model.month == self.selectedDate.month && model.day == self.selectedDate.day;
    BOOL isGray = NO;
    if (collectionView == self.monthCollectionView) {
        if ((model.day > 7 && (indexPath.item % (self.currentMonthDateArray.count / 3)) < 7) || (model.day < 7 && (indexPath.item % (self.currentMonthDateArray.count / 3)) > 14)) {
            isGray = YES;
        }
    }
    [cell setTitle:[NSString stringWithFormat:@"%ld", (long)model.day] isWeekend:isWeekend isSelected:isSelected isGray:isGray];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    DWScheduleDPVModel *model;
    if (self.weekCollectionView == collectionView) {
        model = [self.currentWeekDateArray objectAtIndex:indexPath.row];
    } else if (self.monthCollectionView == collectionView) {
        model = [self.currentMonthDateArray objectAtIndex:indexPath.row];
    }
    self.selectedDate = model;
    if (collectionView == self.monthCollectionView) {
        if (model.day > 7 && indexPath.item < 7 + self.currentMonthDateArray.count / 3) {
            self.monthCollectionView.contentOffset = CGPointMake(0, 0);
            [self scrollViewDidEndDecelerating:self.monthCollectionView];
        } else if (model.day < 7 && indexPath.item > 14 + self.currentMonthDateArray.count / 3) {
            self.monthCollectionView.contentOffset = CGPointMake(self.monthCollectionView.plt_width * 2, 0);
            [self scrollViewDidEndDecelerating:self.monthCollectionView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    scrollView.userInteractionEnabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        scrollView.userInteractionEnabled = YES;
    });
    if (scrollView == self.weekCollectionView) {
        if (scrollView.contentOffset.x < 5) {
            [self lastWeek];
            [self calWeekDateArray];
        } else if (scrollView.contentOffset.x > scrollView.plt_width * 2 - 5) {
            [self nextWeek];
            [self calWeekDateArray];
        }
        [self calCurrentMonthStartDay];
        self.topLabel.text = [NSString stringWithFormat:@"%ld-%02ld", (long)self.monthStartDay.year, (long)self.monthStartDay.month];
    } else if (scrollView == self.monthCollectionView) {
        if (scrollView.contentOffset.x < 5) {
            self.monthStartDay = [self lastMonth];
            [self calMonthDateArray];
        } else if (scrollView.contentOffset.x > scrollView.plt_width * 2 - 5) {
            self.monthStartDay = [self nextMonth];
            [self calMonthDateArray];
        }
        self.topLabel.text = [NSString stringWithFormat:@"%ld-%02ld", (long)self.monthStartDay.year, (long)self.monthStartDay.month];
    }
}


#pragma mark - 布局
///布局
- (void)setupUI {
    self.clipsToBounds = YES;
    UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc] init];
    layout1.itemSize = CGSizeMake(self.plt_width / 7.0, 40);
    layout1.minimumLineSpacing = 0.0f;
    layout1.minimumInteritemSpacing = 0.0f;
    layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.weekCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 70, self.plt_width, 40) collectionViewLayout:layout1];
    self.weekCollectionView.backgroundColor = [UIColor whiteColor];
    self.weekCollectionView.showsVerticalScrollIndicator = NO;
    self.weekCollectionView.showsHorizontalScrollIndicator = NO;
    self.weekCollectionView.delegate = self;
    self.weekCollectionView.dataSource = self;
    self.weekCollectionView.pagingEnabled = YES;
    self.weekCollectionView.bounces = NO;
    [self.weekCollectionView registerClass:[DWScheduleDatePickerViewCell class] forCellWithReuseIdentifier:[DWScheduleDatePickerViewCell plt_cellReuseIdentifier]];
    [self addSubview:self.weekCollectionView];
    
    DWScheduleDatePickerLayout *layout2 = [[DWScheduleDatePickerLayout alloc] init];
    layout2.minimumLineSpacing = 0.0f;
    layout2.minimumInteritemSpacing = 0.0f;
    layout2.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.monthCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 70, self.plt_width, 40) collectionViewLayout:layout2];
    self.monthCollectionView.backgroundColor = [UIColor whiteColor];
    self.monthCollectionView.showsVerticalScrollIndicator = NO;
    self.monthCollectionView.showsHorizontalScrollIndicator = NO;
    self.monthCollectionView.delegate = self;
    self.monthCollectionView.dataSource = self;
    self.monthCollectionView.pagingEnabled = YES;
    self.monthCollectionView.bounces = NO;
    [self.monthCollectionView registerClass:[DWScheduleDatePickerViewCell class] forCellWithReuseIdentifier:[DWScheduleDatePickerViewCell plt_cellReuseIdentifier]];
    [self addSubview:self.monthCollectionView];
    self.monthCollectionView.hidden = YES;
    
    UIView *topBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.plt_width, 70)];
    topBackView.backgroundColor = [UIColor whiteColor];
    [self addSubview:topBackView];
    self.topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.plt_width, 40)];
    self.topLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightThin];
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.topLabel];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(20, self.topLabel.plt_maxY, self.plt_width - 40, 0.75)];
    lineView.backgroundColor = PltColorWithHEX(@"d2d2d2");
    [self addSubview:lineView];
    NSArray *dayArray = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];
    CGFloat itemWidth = self.plt_width / (double)dayArray.count;
    for (int i = 0; i < dayArray.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth * i, self.topLabel.plt_maxY, itemWidth, 30)];
        label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightThin];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [dayArray objectAtIndex:i];
        if (i == 0 || i == dayArray.count - 1) {
            label.textColor = PltColorWithHEX(@"fe5653");
        } else {
            label.textColor = [UIColor blackColor];
        }
        [self addSubview:label];
    }
}

///根据date获取自定义model
- (DWScheduleDPVModel *)getModelWithDate:(NSDate *)date {
    NSString *dateStr = [self.dateFormatter stringFromDate:date];
    DWScheduleDPVModel *model = [[DWScheduleDPVModel alloc] init];
    model.year = [[dateStr substringToIndex:4] integerValue];
    model.month = [[dateStr substringWithRange:NSMakeRange(4, 2)] integerValue];
    model.day = [[dateStr substringFromIndex:dateStr.length - 2] integerValue];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSWeekdayCalendarUnit fromDate:date];
    model.weekDay = [comp weekday] - 1;
    return model;
}

///根据自定义model获取date
- (NSDate *)getDateWithModel:(DWScheduleDPVModel *)model {
    NSDate *date = [self.dateFormatter dateFromString:[NSString stringWithFormat:@"%ld%02ld%02ld", (long)model.year, (long)model.month, (long)model.day]];
    return date;
}

///获取上一星期
- (void)lastWeek {
    self.weekStartDay = [self getModelWithDate:[NSDate dateWithTimeInterval:-7 * 24 * 60 * 60 sinceDate:[self getDateWithModel:self.weekStartDay]]];
    self.weekEndDay = [self getModelWithDate:[NSDate dateWithTimeInterval:-7 * 24 * 60 * 60 sinceDate:[self getDateWithModel:self.weekEndDay]]];
}

///获取下一星期
- (void)nextWeek {
    self.weekStartDay = [self getModelWithDate:[NSDate dateWithTimeInterval:7 * 24 * 60 * 60 sinceDate:[self getDateWithModel:self.weekStartDay]]];
    self.weekEndDay = [self getModelWithDate:[NSDate dateWithTimeInterval:7 * 24 * 60 * 60 sinceDate:[self getDateWithModel:self.weekEndDay]]];
}

///根据月份计算应该显示的星期
- (void)calCurrentWeekDay {
    if (self.monthStartDay.year == self.selectedDate.year && self.monthStartDay.month == self.selectedDate.month) {
        self.weekStartDay = [self getModelWithDate:[NSDate dateWithTimeInterval:-self.selectedDate.weekDay * 24 * 60 * 60 sinceDate:[self getDateWithModel:self.selectedDate]]];
        self.weekEndDay = [self getModelWithDate:[NSDate dateWithTimeInterval:(6 - self.selectedDate.weekDay) * 24 * 60 * 60 sinceDate:[self getDateWithModel:self.selectedDate]]];
        monthOffset = (self.selectedDate.day - self.selectedDate.weekDay + self.monthStartDay.weekDay) / 7 * 40.0f;
    } else {
        self.weekStartDay = [self.currentMonthDateArray objectAtIndex:self.currentMonthDateArray.count / 3];
        self.weekEndDay = [self.currentMonthDateArray objectAtIndex:self.currentMonthDateArray.count / 3 + 6];
        monthOffset = 1.0f;
    }
}

///计算获取当前选择月份
- (void)calCurrentMonthStartDay {
    self.monthStartDay = [[DWScheduleDPVModel alloc] init];
    self.monthStartDay.day = 1;
    NSDate *weekStartDate = [self getDateWithModel:self.weekStartDay];
    NSDate *weekEndDate = [self getDateWithModel:self.weekEndDay];
    NSDate *selectedDate = [self getDateWithModel:self.selectedDate];
    if ([weekStartDate compare:selectedDate] != NSOrderedDescending && [selectedDate compare:weekEndDate] != NSOrderedDescending) {
        self.monthStartDay.year = self.weekStartDay.year;
        self.monthStartDay.month = self.weekStartDay.month;
    } else {
        self.monthStartDay.year = self.weekEndDay.year;
        self.monthStartDay.month = self.weekEndDay.month;
    }
    
    //获取到星期
    self.monthStartDay = [self getModelWithDate:[self getDateWithModel:self.monthStartDay]];
}

///获取上个月
- (DWScheduleDPVModel *)lastMonth {
    DWScheduleDPVModel *model = [[DWScheduleDPVModel alloc] init];
    if (self.monthStartDay.month == 1) {
        model.year = self.monthStartDay.year - 1;
        model.month = 12;
        model.day = 1;
    } else {
        model.year = self.monthStartDay.year;
        model.month = self.monthStartDay.month - 1;
        model.day = 1;
    }
    return [self getModelWithDate:[self getDateWithModel:model]];
}

///获取下个月
- (DWScheduleDPVModel *)nextMonth {
    DWScheduleDPVModel *model = [[DWScheduleDPVModel alloc] init];
    if (self.monthStartDay.month == 12) {
        model.year = self.monthStartDay.year + 1;
        model.month = 1;
        model.day = 1;
    } else {
        model.year = self.monthStartDay.year;
        model.month = self.monthStartDay.month + 1;
        model.day = 1;
    }
    return [self getModelWithDate:[self getDateWithModel:model]];
}


#pragma mark - 懒加载

- (NSMutableArray<DWScheduleDPVModel *> *)currentWeekDateArray {
    if (!_currentWeekDateArray) {
        _currentWeekDateArray = [NSMutableArray arrayWithCapacity:21];
    }
    return _currentWeekDateArray;
}

- (NSMutableArray<DWScheduleDPVModel *> *)currentMonthDateArray {
    if (!_currentMonthDateArray) {
        _currentMonthDateArray = [NSMutableArray arrayWithCapacity:93];
    }
    return _currentMonthDateArray;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyyMMdd"];
        [_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"zh_CN"]];
    }
    return _dateFormatter;
}

@end
