varying lowp vec4 destinationColor;

varying lowp vec2 texCoordOut;
uniform sampler2D texture;

void main(void) {
	gl_FragColor = destinationColor * texture2D(texture, texCoordOut);
}
