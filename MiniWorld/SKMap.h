//
//  SKMap.h
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteKit.h"

@interface SKMap : NSObject

@property (readonly, nonatomic) NSInteger width;
@property (readonly, nonatomic) NSInteger height;

@property (strong, nonatomic) SKTexture *texture;

- (id)initWithWidth:(NSInteger)width height:(NSInteger)height textureMap:(SKTexture*)texture;

@end
