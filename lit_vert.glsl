#version 460

in vec3 vaPosition;
in vec2 vaUV0;
in vec4 vaColor;
in ivec2 vaUV2;
in vec3 vaNormal;
in vec4 at_tangent;

uniform vec3 chunkOffset;
uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

out vec2 texCoord;
out vec3 foliageColor;
out vec2 lightMapCoords;
out vec3 geoNormal;
out vec4 tangent;
out vec3 viewSpacePosition;

void main(){
    tangent = vec4(normalize(normalMatrix * at_tangent.rgb), at_tangent.a);
    geoNormal = normalMatrix * vaNormal;

    lightMapCoords = vaUV2 * (1.0 / 256.0) + (1.0 / 32.0);   //ivec2 to vec2

    texCoord = vaUV0;
    foliageColor = vaColor.rgb;


    gl_Position = projectionMatrix * modelViewMatrix * vec4(vaPosition + chunkOffset, 1);
}