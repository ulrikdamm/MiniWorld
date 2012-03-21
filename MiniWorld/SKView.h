//
//  GLView.h
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKShader.h"

@class SKSprite;

@interface SKView : UIView

@property (strong, nonatomic) SKShader *shader;

- (void)addSprite:(SKSprite*)sprite;
- (void)removeSprite:(SKSprite*)sprite;
- (BOOL)containsSprite:(SKSprite*)sprite;
- (int)spriteCount;
- (void)setSpriteGroup:(NSString*)group;
- (BOOL)hasSpriteGroup:(NSString*)group;
- (NSString*)currentSpriteGroup;

- (void)render;

@end
