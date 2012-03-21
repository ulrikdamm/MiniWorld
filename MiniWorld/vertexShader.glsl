attribute vec4 position;
attribute vec4 sourceColor;

uniform mat4 projection;
uniform mat4 modelView;

varying vec4 destinationColor;

attribute vec2 texCoordIn;
varying vec2 texCoordOut;

void main(void) {
	destinationColor = sourceColor;
	gl_Position = position * modelView * projection;
	texCoordOut = texCoordIn;
}
