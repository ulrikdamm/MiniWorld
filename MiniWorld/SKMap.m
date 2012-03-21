//
//  SKMap.m
//  MiniWorld
//
//  Created by Ulrik Damm on 23/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#import "SKMap.h"

@interface SKMap () {
	SKVertex *vertices;
	int vertexCount;
	
	GLushort *indicies;
	int indexCount;
}

@property (assign, nonatomic) NSInteger width;
@property (assign, nonatomic) NSInteger height;

- (void)setupModel;

@end

@implementation SKMap

@synthesize width;
@synthesize height;
@synthesize texture;

- (id)initWithWidth:(NSInteger)newwidth height:(NSInteger)newheight textureMap:(SKTexture*)newtexture {
	if ((self = [super init])) {
		self.width = newwidth;
		self.height = newheight;
		self.texture = newtexture;
		
		[self setupModel];
	}
	
	return self;
}

- (void)setupModel {
	vertexCount = (width + 1) * (height + 1);
	vertices = (SKVertex*)calloc(vertexCount, sizeof(SKVertex));
	
	indexCount = (width - 1) * height * 4 + height * 2;
	indicies = (GLushort*)calloc(vertexCount, sizeof(GLushort));
	
	int indiciesPerRow = 4 * (width - 1) + 2;
	int verticesPerRow = width + 1;
	
	int i;
	for (i = 0; i < indexCount; i++) {
		int row = i / indiciesPerRow;
		int rowindex = i % indiciesPerRow;
		int column = (rowindex == 0 || rowindex == 1? 0: rowindex == indiciesPerRow - 1? width: (rowindex - 1) / 2);
		int rowpos = (rowindex == 0? 1: rowindex == indiciesPerRow - 1? 0: (rowindex - 1) % 2 == 0);
		int rowstart = row + rowpos;
		int finalrow = rowstart * verticesPerRow;
		int final = finalrow + column;
		
		indicies[i] = final;
	}
	
	for (i = 0; i < vertexCount; i++) {
		int x = i % verticesPerRow;
		int y = i / verticesPerRow;
		
		SKVertex vertex = { x, y, 1, 1, 1, 1, 0, 0 };
		
		memcpy(&vertices[i], &vertex, sizeof(SKVertex));
	}
}

@end
