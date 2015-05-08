//
//  ReceiptCollectionFlowLayout.m
//  uberhxthon
//
//  Created by Ashwin Kumar on 5/7/15.
//  Copyright (c) 2015 Catherine Jue & Ashwin Kumar. All rights reserved.
//

#import "ReceiptCollectionFlowLayout.h"
#import <objc/runtime.h>
#import "ReceiptSectionHeaderView.h"

@interface ReceiptCollectionFlowLayout ()

@property (nonatomic, assign) BOOL isBoring;

// Containers for keeping track of changing items
@property (nonatomic, strong) NSMutableArray *insertedIndexPaths;
@property (nonatomic, strong) NSMutableArray *removedIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedSectionIndices;
@property (nonatomic, strong) NSMutableArray *removedSectionIndices;

// Caches for keeping current/previous attributes
@property (nonatomic, strong) NSMutableDictionary *currentCellAttributes;
@property (nonatomic, strong) NSMutableDictionary *currentSupplementaryAttributesByKind;
@property (nonatomic, strong) NSMutableDictionary *cachedCellAttributes;
@property (nonatomic, strong) NSMutableDictionary *cachedSupplementaryAttributesByKind;

// Use to compute previous location of other cells when cells get removed/inserted
- (NSIndexPath*)previousIndexPathForIndexPath:(NSIndexPath*)indexPath accountForItems:(BOOL)checkItems;

@end

@implementation ReceiptCollectionFlowLayout

- (id)init
{
    self = [super init];
    if (self)
    {
        self.isBoring = NO;
        self.currentCellAttributes = [NSMutableDictionary dictionary];
        self.currentSupplementaryAttributesByKind = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)makeBoring
{
    self.isBoring = YES;
}

#pragma mark - Subclass

- (void)prepareLayout
{
    [super prepareLayout];
    
    // Deep-copy attributes in current cache
    self.cachedCellAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.currentCellAttributes copyItems:YES];
    self.cachedSupplementaryAttributesByKind = [NSMutableDictionary dictionary];
    [self.currentSupplementaryAttributesByKind enumerateKeysAndObjectsUsingBlock:^(NSString *kind, NSMutableDictionary * attribByPath, BOOL *stop) {
        NSMutableDictionary * cachedAttribByPath = [[NSMutableDictionary alloc] initWithDictionary:attribByPath copyItems:YES];
        [self.cachedSupplementaryAttributesByKind setObject:cachedAttribByPath forKey:kind];
    }];
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray * attributes = [super layoutAttributesForElementsInRect:rect];
    
    // Always cache all visible attributes so we can use them later when computing final/initial animated attributes
    // Never clear the cache as certain items may be removed from the attributes array prior to being animated out
    [attributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL *stop) {
        
        if (attributes.representedElementCategory == UICollectionElementCategoryCell)
        {
            [self.currentCellAttributes setObject:attributes
                                           forKey:attributes.indexPath];
        }
        else if (attributes.representedElementCategory == UICollectionElementCategorySupplementaryView)
        {
            NSMutableDictionary *supplementaryAttribuesByIndexPath = [self.currentSupplementaryAttributesByKind objectForKey:attributes.representedElementKind];
            if (supplementaryAttribuesByIndexPath == nil)
            {
                supplementaryAttribuesByIndexPath = [NSMutableDictionary dictionary];
                [self.currentSupplementaryAttributesByKind setObject:supplementaryAttribuesByIndexPath forKey:attributes.representedElementKind];
            }
            
            [supplementaryAttribuesByIndexPath setObject:attributes
                                                  forKey:attributes.indexPath];
        }
        
    }];
    
    return attributes;
}


- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    
    if (!self.isBoring)
    {
        // Keep track of updates to items and sections so we can use this information to create nifty animations
        self.insertedIndexPaths     = [NSMutableArray array];
        self.removedIndexPaths      = [NSMutableArray array];
        self.insertedSectionIndices = [NSMutableArray array];
        self.removedSectionIndices  = [NSMutableArray array];
        
        
        [updateItems enumerateObjectsUsingBlock:^(UICollectionViewUpdateItem *updateItem, NSUInteger idx, BOOL *stop) {
            if (updateItem.updateAction == UICollectionUpdateActionInsert)
            {
                // If the update item's index path has an "item" value of NSNotFound, it means it was a section update, not an individual item.
                // This is 100% undocumented but 100% reproducible.
                
                if (updateItem.indexPathAfterUpdate.item == NSNotFound)
                {
                    [self.insertedSectionIndices addObject:@(updateItem.indexPathAfterUpdate.section)];
                }
                else
                {
                    [self.insertedIndexPaths addObject:updateItem.indexPathAfterUpdate];
                }
            }
            else if (updateItem.updateAction == UICollectionUpdateActionDelete)
            {
                if (updateItem.indexPathBeforeUpdate.item == NSNotFound)
                {
                    [self.removedSectionIndices addObject:@(updateItem.indexPathBeforeUpdate.section)];
                    
                }
                else
                {
                    [self.removedIndexPaths addObject:updateItem.indexPathBeforeUpdate];
                }
            }
        }];
    }
}

// These layout attributes are applied to a cell that is "appearing" and will be eased into the nominal layout attributes for that cell
// Cells "appear" in several cases:
//  - Inserted explicitly or via a section insert
//  - Moved as a result of an insert at a lower index path
//  - Result of an animated bounds change repositioning cells
- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    if (!self.isBoring)
    {
        if ([self.insertedIndexPaths containsObject:itemIndexPath])
        {
            // If this is a newly inserted item, make it grow into place from its nominal index path
            attributes = [[self.currentCellAttributes objectForKey:itemIndexPath] copy];
            attributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0);
        }
        else if ([self.insertedSectionIndices containsObject:@(itemIndexPath.section)])
        {
            // if it's part of a new section, fly it in from the left
            attributes = [[self.currentCellAttributes objectForKey:itemIndexPath] copy];
            attributes.transform3D = CATransform3DMakeTranslation(-self.collectionView.bounds.size.width, 0, 0);
        }
        
    }
    return attributes;
}

// These layout attributes are applied to a cell that is "disappearing" and will be eased to from the nominal layout attribues prior to disappearing
// Cells "disappear" in several cases:
//  - Removed explicitly or via a section removal
//  - Moved as a result of a removal at a lower index path
//  - Result of an animated bounds change repositioning cells
- (UICollectionViewLayoutAttributes*)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    
    if (!self.isBoring)
    {
        
        if ([self.removedIndexPaths containsObject:itemIndexPath] || [self.removedSectionIndices containsObject:@(itemIndexPath.section)])
        {
            // Make it fall off the screen with a slight rotation
            attributes = [[self.cachedCellAttributes objectForKey:itemIndexPath] copy];
            CATransform3D transform = CATransform3DMakeTranslation(0, self.collectionView.bounds.size.height, 0);
            transform = CATransform3DRotate(transform, M_PI*0.2, 0, 0, 1);
            attributes.transform3D = transform;
            attributes.alpha = 0.0f;
        }
    }
    return attributes;
}

// These layout attributes are applied to newly appearing supplementary views, which are then eased to their nominal attributes
// Supplementary views in a flow layout normally only appear when adding a section
- (UICollectionViewLayoutAttributes*)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
    
    if (!self.isBoring)
    {
        if ([self.insertedSectionIndices containsObject:@(elementIndexPath.section)])
        {
            attributes = [[[self.currentSupplementaryAttributesByKind objectForKey:elementKind] objectForKey:elementIndexPath] copy];
            attributes.transform3D = CATransform3DMakeTranslation(-self.collectionView.bounds.size.width, 0, 0);
        }
        else
        {
            // Start it right where it was before if nothing is changing
            NSIndexPath *prevPath = [self previousIndexPathForIndexPath:elementIndexPath accountForItems:NO];
            attributes = [[[self.cachedSupplementaryAttributesByKind objectForKey:elementKind] objectForKey:prevPath] copy];
        }
        
    }
    
    return attributes;
}

// These layout attributes are eased to in disappearing supplementary views from their current attributes
// Supplementary views in a flow layout normally only disappear when deleting a section
- (UICollectionViewLayoutAttributes*)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath
{
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
    
    if (!self.isBoring)
    {
        if ([self.removedSectionIndices containsObject:@(elementIndexPath.section)])
        {
            attributes = [[[self.cachedSupplementaryAttributesByKind objectForKey:elementKind] objectForKey:elementIndexPath] copy];
            CATransform3D transform = CATransform3DMakeTranslation(0, self.collectionView.bounds.size.height, 0);
            transform = CATransform3DRotate(transform, M_PI*0.2, 0, 0, 1);
            attributes.transform3D = transform;
            attributes.alpha = 0.0f;
        }
        else
        {
            // Keep it right where it is
            attributes = [[[self.currentCellAttributes objectForKey:elementKind] objectForKey:elementIndexPath] copy];
        }
        
    }
    return attributes;
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    
    self.insertedIndexPaths     = nil;
    self.removedIndexPaths      = nil;
    self.insertedSectionIndices = nil;
    self.removedSectionIndices  = nil;
}


#pragma mark - Helpers

- (NSIndexPath*)previousIndexPathForIndexPath:(NSIndexPath *)indexPath accountForItems:(BOOL)checkItems
{
    __block NSInteger section = indexPath.section;
    __block NSInteger item = indexPath.item;
    
    [self.removedSectionIndices enumerateObjectsUsingBlock:^(NSNumber *rmSectionIdx, NSUInteger idx, BOOL *stop) {
        if ([rmSectionIdx integerValue] <= section)
        {
            section++;
        }
    }];
    
    if (checkItems)
    {
        [self.removedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *rmIndexPath, NSUInteger idx, BOOL *stop) {
            if ([rmIndexPath section] == section && [rmIndexPath item] <= item)
            {
                item++;
            }
        }];
    }
    
    [self.insertedSectionIndices enumerateObjectsUsingBlock:^(NSNumber *insSectionIdx, NSUInteger idx, BOOL *stop) {
        if ([insSectionIdx integerValue] < [indexPath section])
        {
            section--;
        }
    }];
    
    if (checkItems)
    {
        [self.insertedIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath *insIndexPath, NSUInteger idx, BOOL *stop) {
            if ([insIndexPath section] == [indexPath section] && [insIndexPath item] < [indexPath item])
            {
                item--;
            }
        }];
    }
    
    return [NSIndexPath indexPathForItem:item inSection:section];
}

@end
