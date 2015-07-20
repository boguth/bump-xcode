//
//  StretchyHeaderCollectionViewLayout.m
//  Bump
//
//  Created by Apprentice on 7/19/15.
//  Copyright (c) 2015 Bump Boys!, Inc. All rights reserved.
//

#import "StretchyHeaderCollectionViewLayout.h"

@implementation StretchyHeaderCollectionViewLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    // This will schedule calls to layoutAttributesForElementsInRect: as the
    // collectionView is scrolling.
    return YES;
}

- (UICollectionViewScrollDirection)scrollDirection {
    // This subclass only supports vertical scrolling.
    return UICollectionViewScrollDirectionVertical;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    UICollectionView *collectionView = [self collectionView];
    UIEdgeInsets insets = [collectionView contentInset];
    CGPoint offset = [collectionView contentOffset];
    CGFloat minY = -insets.top;
    
    // First get the superclass attributes.
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    // Check if we've pulled below past the lowest position
    if (offset.y < minY) {
        
        // Figure out how much we've pulled down
        CGFloat deltaY = fabsf(offset.y - minY);
        
        for (UICollectionViewLayoutAttributes *attrs in attributes) {
            
            // Locate the header attributes
            NSString *kind = [attrs representedElementKind];
            if (kind == UICollectionElementKindSectionHeader) {
                
                // Adjust the header's height and y based on how much the user
                // has pulled down.
                CGSize headerSize = [self headerReferenceSize];
                CGRect headerRect = [attrs frame];
                headerRect.size.height = MAX(minY, headerSize.height + deltaY);
                headerRect.origin.y = headerRect.origin.y - deltaY;
                [attrs setFrame:headerRect];
                break;
            }
        }
    }
    return attributes;
}

@end
