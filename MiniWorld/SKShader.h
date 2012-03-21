//
//  SKShader.h
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKShader : NSObject

- (void)addSource:(NSString*)source ofType:(GLenum)type error:(NSError* __autoreleasing*)error;
- (void)linkProgram:(__autoreleasing NSError**)error;

@property (readonly, nonatomic) GLuint programId;

@end
