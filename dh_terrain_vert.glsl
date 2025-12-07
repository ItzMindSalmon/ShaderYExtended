#version 460 compatibility

out vec4 blockColor;
out vec2 lightMapCoords;
out vec3 viewSpacePosition;
out vec3 geoNormal;

void main(){
    geoNormal = gl_Normal * gl_NormalMatrix;
    lightMapCoords =(gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;   //complex code that is impossible to understand

    blockColor = gl_Color;
    viewSpacePosition = (gl_ModelViewMatrix * gl_Vertex).xyz;

    gl_Position = ftransform();
}