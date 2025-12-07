#version 460
#define FUNCTION_INCLUDE

uniform sampler2D normals;
uniform sampler2D specular;
uniform sampler2D gtexture;
uniform sampler2D lightmap;

uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

/* DRAWBUFFERS: 0 */
layout(location = 0) out vec4 outColor0;

in vec3 foliageColor;
in vec2 texCoord;
in vec3 viewSpacePosition;
in vec2 lightMapCoords;
in vec3 geoNormal;
in vec4 tangent;

#include "/programs/functions.glsl"

void main(){
    vec4 outputColorData = pow(texture(gtexture, texCoord), vec4(2.2));
    vec3 albedo = pow(outputColorData.rgb, vec3(2.2)) * pow(foliageColor, vec3(2.2));
    vec3 outputColor = lightningCalcutations(albedo);

    // remove the color thing behind grasses and flowers
    float transparency = outputColorData.a;
    if(transparency < .1){
        discard;
    }

    //output
    outColor0 = pow(vec4(pow(outputColor, vec3(1 / 2.2)), transparency), vec4(1 / 2.2)); // gamma -> linear
}