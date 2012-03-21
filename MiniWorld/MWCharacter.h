//
//  MWCharacter.h
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteKit.h"
#import "MWViewController.h"
#import "MWObject.h"

@interface MWCharacter : MWObject

@property (readonly, nonatomic) CGPoint lookingAt;
@property (assign, nonatomic) MWMap *map;

- (void)moveInDirection:(MWDirection)direction;

@end
