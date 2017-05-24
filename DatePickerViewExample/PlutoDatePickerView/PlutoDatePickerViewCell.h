//
//  PlutoDatePickerViewCell.h
//  DatePickerViewExample
//
//  Created by Dareway on 2017/5/24.
//  Copyright © 2017年 Pluto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlutoDatePickerViewCell : UICollectionViewCell
- (void)setTitle:(NSString *)title isWeekend:(BOOL)isWeekend isSelected:(BOOL)isSelected isGray:(BOOL)isGray;
@end
