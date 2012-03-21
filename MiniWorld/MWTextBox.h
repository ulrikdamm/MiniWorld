//
//  MWTextBox.h
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpriteKit.h"
#import "global.h"

@interface MWTextBox : NSObject

@property (strong, nonatomic) SKSprite *sprite;
@property (strong, nonatomic) NSMutableArray *messages;
@property (copy, nonatomic) void (^completionBlock)(int);
@property (readonly, nonatomic) int messagesShown;

- (id)initWithMessages:(NSMutableArray*)messages texture:(SKTexture*)texture shader:(SKShader*)shader;
- (BOOL)nextMessage;
- (void)update;

- (void)changeChoice:(MWDirection)direction;

@end
