//
//  MWObject.h
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteKit.h"
#import "MWMap.h"

@interface MWObject : NSObject

@property (assign, nonatomic) CGPoint position;
@property (strong, nonatomic) SKSprite *sprite;
@property (assign, nonatomic) MWMap *map;
@property (assign, nonatomic, getter = isBlocking) BOOL blocking;
@property (copy, nonatomic) void(^interactionBlock)(void);
@property (copy, nonatomic) void(^actionBlock)(void);

- (id)initWithShader:(SKShader*)shader texture:(SKTexture*)texture;
- (void)update;
- (void)interact:(MWObject*)object;
- (void)action:(MWObject*)object;

@end
