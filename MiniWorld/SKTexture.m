//
//  SKTexture.m
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "SKTexture.h"
#import <OpenGLES/ES2/gl.h>

@interface SKTexture ()

@property (assign, nonatomic) CGSize size;

@end

@implementation SKTexture

@synthesize textureId;
@synthesize size;

- (id)initWithImage:(UIImage*)image {
	if ((self = [super init])) {
		CGImageRef graphic = image.CGImage;
		
		size_t width = CGImageGetWidth(graphic);
		size_t height = CGImageGetHeight(graphic);
		
		size = CGSizeMake(width, height);
		
		GLubyte *data = (GLubyte*)calloc(width * height * 4, sizeof(GLubyte));
		
		CGContextRef context = CGBitmapContextCreate(data, width, height, 8, width * 4, CGImageGetColorSpace(graphic), kCGImageAlphaPremultipliedLast);
		CGContextDrawImage(context, CGRectMake(0, 0, width, height), graphic);
		CGContextRelease(context);
		
		glGenTextures(1, &textureId);
		glBindTexture(GL_TEXTURE_2D, textureId);
		
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
		
		free(data);
	}
	
	return self;
}

@end
