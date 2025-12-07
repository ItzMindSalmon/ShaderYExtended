#version 460 compatibility

uniform sampler2D lightmap;
uniform sampler2D depthtex0;
uniform float viewHeight;
uniform float viewWidth;
uniform vec3 fogColor;
uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;

/* DRAWBUFFERS: 0 */
layout(location = 0) out vec4 outColor0;

in vec4 blockColor;
in vec2 lightMapCoords;
in vec3 viewSpacePosition;
in vec3 geoNormal;

void main(){
    //light for distance horizon rendering
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);

    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;


    vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2));

    vec4 outputColorData = blockColor;
    vec3 outputColor = outputColorData.rgb * lightColor;

    // remove the color thing behind grasses and flowers
    float transparency = outputColorData.a;
    if(transparency < .1){
        discard;
    }
    vec2 texCoord = gl_FragCoord.xy / vec2(viewWidth, viewHeight);  //define the depth of an object
    float depth = texture(depthtex0, texCoord).r;
    if (depth != 1.0){
        discard;
    }


    //fog for distance horizon
    float distanceFromCamera = distance(vec3(0), viewSpacePosition); 

    float maxFogDistance = 4000;
    float minFogDistance = 2500;

    float fogBlendValue = clamp((distanceFromCamera - minFogDistance) / (maxFogDistance - minFogDistance), 0, 1);

    outputColor = mix(outputColor, pow(fogColor, vec3(2.2)), fogBlendValue);
    outColor0 = pow(vec4(pow(outputColor, vec3(1/2.2)), transparency), vec4(1/2.2));
}