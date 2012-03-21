//
//  SKTexture.h
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKTexture : NSObject

- (id)initWithImage:(UIImage*)image;

@property (readonly, nonatomic) GLuint textureId;
@property (readonly, nonatomic) CGSize size;

@end
