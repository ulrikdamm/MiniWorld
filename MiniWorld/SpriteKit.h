//
//  SpriteKit.h
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "SKSprite.h"
#import "SKTexture.h"
#import "SKMatrix.h"
#import "SKShader.h"
#import "SKView.h"
#import "SKMap.h"

typedef struct {
	GLfloat position[3];
	GLfloat color[4];
	GLfloat tex[2];
} SKVertex;
