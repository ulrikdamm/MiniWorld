//
//  SKSprite.h
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteKit.h"
#import "SKShader.h"
#import "SKTexture.h"

@interface SKSprite : NSObject

@property (assign, nonatomic) CGPoint position;
@property (assign, nonatomic) CGSize size;
@property (strong, nonatomic) SKShader *shader;
@property (assign, nonatomic) CGRect textureClip;
@property (strong, nonatomic) SKTexture *texture;
@property (assign, nonatomic) CGPoint anchor;
@property (assign, nonatomic) BOOL alpha;
@property (assign, nonatomic) int zpos;
@property (strong, nonatomic) NSMutableArray *subsprites;
@property (assign, nonatomic) BOOL visible;

- (id)initWithTexture:(SKTexture*)texture shader:(SKShader*)shader;
- (void)draw;

@end
