//
//  MWMap.h
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MWObject;

@interface MWMap : NSObject

@property (strong, nonatomic) NSMutableArray *objects;
@property (assign, nonatomic) CGSize size;

- (void)update;
- (void)addObject:(MWObject*)object;
- (BOOL)isBlocked:(CGPoint)position;
- (void)interactWith:(CGPoint)point;
- (void)standUpon:(CGPoint)point;

@end
