//
//  SKMatrix.c
//  spriteKit
//
//  Created by Ulrik Damm on 22/1/12.
//  Copyright (c) 2012 Gereen.dk. All rights reserved.
//

#include "SKMatrix.h"
#include <string.h>
#include <stdio.h>
#include <math.h>

SKMatrix SKMatrixZero(void) {
	SKMatrix matrix;
	
	GLfloat values[16] = {
		1,	0,	0,	0,
		0,	1,	0,	0,
		0,	0,	0,	0,
		0,	0,	0,	1,
	};
	
	memcpy(matrix.values, values, sizeof(values));
	
	return matrix;
}

SKMatrix SKMatrixWithValues(GLfloat *values) {
	SKMatrix matrix;
	memcpy(matrix.values, values, sizeof(GLfloat) * 16);
	return matrix;
}

SKMatrix SKMatricCopy(SKMatrix *matrix) {
	return SKMatrixWithValues(matrix->values);
}

void SKMatrixOrtho(SKMatrix *matrix, GLfloat left, GLfloat right, GLfloat top, GLfloat bottom, GLfloat near, GLfloat far) {
	GLfloat values[16] = {
		2.0f / (right - left),	0,						0,						-((right + left) / (right - left)),
		0,						2.0f / (top - bottom),	0,						-((top + bottom) / (top - bottom)),
		0,						0,						-2.0f / (near - far),	-((near + far) / (near - far)),
		0,						0,						0,						1,
	};
	
	SKMatrix multiplier = SKMatrixWithValues(values);
	SKMatrixMultiply(matrix, &multiplier);
}

void SKMatrixFrustum(SKMatrix *matrix, GLfloat left, GLfloat right, GLfloat bottom, GLfloat top, GLfloat near, GLfloat far) {
	GLfloat values[16] = {
		(2.0f * near) / (right - left),	0,								(right + left) / (right - left),	0,
		0,								(2.0f * near) / (top - bottom),	(top + bottom) / (top - bottom),	0,
		0,								0,								-((far + near) / (far - near)),		-((2 * far * near) / (far - near)),
		0,								0,								-1.0f,								0,
	};
	
	SKMatrix multiplier = SKMatrixWithValues(values);
	SKMatrixMultiply(matrix, &multiplier);
}

void SKMatrixSwitchColumnsAndRows(SKMatrix *matrix) {
	GLfloat values[16] = {
		matrix->m1,	 matrix->m1,  matrix->m2,  matrix->m3,
		matrix->m4,	 matrix->m5,  matrix->m7,  matrix->m8,
		matrix->m9,	 matrix->m10, matrix->m11, matrix->m12,
		matrix->m13, matrix->m14, matrix->m15, matrix->m16,
	};
	
	SKMatrix multiplier = SKMatrixWithValues(values);
	SKMatrixMultiply(matrix, &multiplier);
}

void SKMatrixTranslate(SKMatrix *matrix, GLfloat x, GLfloat y, GLfloat z) {
	GLfloat values[16] = {
		1,	0,	0,	x,
		0,	1,	0,	y,
		0,	0,	1,	z,
		0,	0,	0,	1,
	};
	
	SKMatrix multiplier = SKMatrixWithValues(values);
	SKMatrixMultiply(matrix, &multiplier);
}

void SKMatrixRotate(SKMatrix *matrix, GLfloat x, GLfloat y, GLfloat z, GLfloat value) {
	GLfloat c = cos(value);
	GLfloat s = sin(value);
	
	GLfloat values[16] = {
		(x*x)*(1-c)+c,		(x*y)*(1-c)-(z*s),	(x*z)*(1-c)+(y*s),	0,
		(y*x)*(1-c)+(z*s),	(y*y)*(1-c)+c,		(y*z)*(1-c)-(x*s),	0,
		(x*z)*(1-c)-(y*s),	(y*z)*(1-c)+(x*s),	(z*z)*(1-c)+c,		0,
		0,					0,					0,					1,
	};
	
	SKMatrix multiplier = SKMatrixWithValues(values);
	SKMatrixMultiply(matrix, &multiplier);
}

void SKMatrixScale(SKMatrix *matrix, GLfloat x, GLfloat y, GLfloat z) {
	GLfloat values[16] = {
		x,	0,	0,	0,
		0,	y,	0,	0,
		0,	0,	z,	0,
		0,	0,	0,	1,
	};
	
	SKMatrix multiplier = SKMatrixWithValues(values);
	SKMatrixMultiply(matrix, &multiplier);
}

void SKMatrixMultiply(SKMatrix *matrix, SKMatrix *multiplierMatrix) {
	GLfloat values[16];
	
	int i;
	for (i = 0; i < 16; i++) {
		int row = i / 4;
		int col = i % 4;
		
		GLfloat val1 = matrix->values[row * 4 + 0] * multiplierMatrix->values[col + 4 * 0];
		GLfloat val2 = matrix->values[row * 4 + 1] * multiplierMatrix->values[col + 4 * 1];
		GLfloat val3 = matrix->values[row * 4 + 2] * multiplierMatrix->values[col + 4 * 2];
		GLfloat val4 = matrix->values[row * 4 + 3] * multiplierMatrix->values[col + 4 * 3];
		
		values[i] = val1 + val2 + val3 + val4;
	}
	
	memcpy(matrix->values, values, sizeof(values));
}

void SKMatrixPrint(SKMatrix *matrix) {
	printf("%f,\t%f,\t%f,\t%f,\n%f,\t%f,\t%f,\t%f,\n%f,\t%f,\t%f,\t%f,\n%f,\t%f,\t%f,\t%f,",
		   matrix->m1, matrix->m5, matrix->m9,  matrix->m13,
		   matrix->m2, matrix->m6, matrix->m10, matrix->m14, 
		   matrix->m3, matrix->m7, matrix->m11, matrix->m15,
		   matrix->m4, matrix->m8, matrix->m12, matrix->m16);
}
