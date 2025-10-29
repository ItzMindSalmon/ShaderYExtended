#version 460

//uniforms
uniform sampler2D gtexture;
uniform sampler2D lightmap;
uniform sampler2D normals;
uniform sampler2D specular;

uniform mat4 gbufferModelViewInverse;
uniform vec3 shadowLightPosition;
uniform vec3 cameraPosition;

/* DRAWBUFFERS: 0 */
layout(location = 1) out vec4 outColor0;

in vec3 foliageColor;
in vec2 texCoord;
in vec2 lightMapCoords;
in vec3 geoNormal;
in vec4 tangent;
in vec3 viewSpacePosition;

//function
mat3 tbnNormalTangent(vec3 normal, vec3 tangent){
    vec3 bitangent = cross(tangent, normal);
    return mat3(tangent, bitangent, normal);
}

void main(){
    //resource pack support
    vec4 normalData = texture(normals, texCoord) * 2.0 - 1.0;
    vec3 normalNormalSpace = vec3(normalData.xy, sqrt(1.0 - dot(normalData.xy, normalData.xy)));

    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;
    vec3 worldTangent = mat3(gbufferModelViewInverse) * tangent.xyz;

    mat3 tbn = tbnNormalTangent(worldGeoNormal, tangent.rgb);
    vec3 normalWorldSpace = tbn * normalNormalSpace;

    //light brightness (still figuring out why the texture doesn't feel like vanilla)
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);
    vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2)); // linear -> gamma

    /*specular (in light brightness)*/
    vec4 specularData = texture(specular, texCoord);
    vec3 fragFeetPlayerSpace = (gbufferModelViewInverse * vec4(viewSpacePosition, 1.0)).xyz;
    vec3 fragWorldSpace = fragFeetPlayerSpace + cameraPosition;

    vec3 viewPosition = normalize(cameraPosition - fragWorldSpace);
    vec3 reflectionDirection = reflect(shadowLightDirection, normalWorldSpace);
  
    float perceptualSmoothness = specularData.r;
    float roughness = pow(1.0 - perceptualSmoothness, 2.0);
    float smoothness = 1 - roughness;

    vec4 outputColorData = pow(texture(gtexture, texCoord), vec4(2.2));
    vec3 outputColor = outputColorData.rgb * pow(foliageColor, vec3(2.2)) * lightColor;

    float diffuseLight = roughness * clamp(dot(shadowLightDirection, worldGeoNormal), 0.0, 1.0);
    float ambientLight = 0.2;
    float specularLight = smoothness * dot(shadowLightDirection, viewPosition);
    float lightBrightness = ambientLight + diffuseLight + specularLight;
    // ^ light brightness

    // remove the color thing behind grasses and flowers
    float transparency = outputColorData.a;
    if(transparency < .1){
        discard;
    }

    //output
    outputColor *= diffuseLight;
    outColor0 = pow(vec4(pow(outputColor, vec3(1 / 2.2)), transparency), vec4(1 / 2.2)); // gamma -> linear
}