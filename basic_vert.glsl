#version 460

in vec3 vaPosition;
in vec2 vaUV0;
in vec4 vaColor;

uniform vec3 chunkOffset;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

out vec2 texCoord;
out vec3 foliageColor;

void main(){

    texCoord = vaUV0;
    foliageColor = vaColor.rgb;

    gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition + chunkOffset, 1);
}