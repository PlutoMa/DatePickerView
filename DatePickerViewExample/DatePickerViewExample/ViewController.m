//
//  ViewController.m
//  DatePickerViewExample
//
//  Created by Pluto on 2017/5/24.
//  Copyright © 2017年 Pluto. All rights reserved.
//

#import "ViewController.h"
#import "PlutoDatePickerView.h"

@interface ViewController () <PlutoDatePickerViewDelegate>
@property (nonatomic, strong) PlutoDatePickerView *datePickerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.datePickerView = [[PlutoDatePickerView alloc] initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].bounds.size.width, 110) delegate:self];
    [self.view addSubview:self.datePickerView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.datePickerView.isSetDate) {
        [self.datePickerView setCurrentDate:[NSDate date]];
    }
}

#pragma mark - PlutoDatePickerViewDelegate

- (void)pickerView:(PlutoDatePickerView *)pickerView didSelectTime:(PlutoDPVModel *)time {
    if (pickerView == self.datePickerView) {
        NSLog(@"%@-->%@-->%@", @(time.year), @(time.month), @(time.day));
    }
}


@end
