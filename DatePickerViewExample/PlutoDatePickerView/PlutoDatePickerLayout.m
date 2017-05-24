//
//  PlutoDatePickerLayout.m
//  DatePickerViewExample
//
//  Created by Pluto on 2017/5/24.
//  Copyright © 2017年 Pluto. All rights reserved.
//

#import "PlutoDatePickerLayout.h"

@interface PlutoDatePickerLayout ()
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributeArray;
@end

@implementation PlutoDatePickerLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    self.itemSize = CGSizeMake(self.collectionView.frame.size.width / 7.0, 40);
    
    [self.attributeArray removeAllObjects];
    for (int index = 0; index < [self.collectionView numberOfItemsInSection:0]; index++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attributeArray addObject:attributes];
    }
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attributeArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSUInteger count = [self.collectionView numberOfItemsInSection:0];
    NSUInteger onePageCount = count / 3;
    //获取所在页
    NSUInteger page = indexPath.item / onePageCount;
    //获取所在行
    NSUInteger row = (indexPath.item % onePageCount) / 7;
    //获取所在列
    NSUInteger column = indexPath.item % 7;
    //设定位置
    CGRect rect = CGRectMake(self.collectionView.frame.size.width * page + self.itemSize.width * column, self.itemSize.height * row, self.itemSize.width, self.itemSize.height);
    attributes.frame = rect;
    return attributes;
}

- (CGSize)collectionViewContentSize {
    NSUInteger count = [self.collectionView numberOfItemsInSection:0];
    count = count / 3;
    NSUInteger rowCount = count / 7;
    return CGSizeMake(self.collectionView.frame.size.width * 3, self.itemSize.height * rowCount);
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return NO;
}


- (NSMutableArray<UICollectionViewLayoutAttributes *> *)attributeArray {
    if (!_attributeArray) {
        _attributeArray = [NSMutableArray array];
    }
    return _attributeArray;
}

@end
