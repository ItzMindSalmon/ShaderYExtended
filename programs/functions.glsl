#ifdef FUNCTION_INCLUDE
#endif
#include "/programs/brdf.glsl"


//function
mat3 tbnNormalTangent(vec3 normal, vec3 tangent){
    vec3 bitangent = cross(tangent, normal);
    return mat3(tangent, bitangent, normal);
}

vec3 lightningCalcutations(vec3 albedo){
    //resource pack support
    vec4 normalData = texture(normals, texCoord) * 2.0 - 1.0;
    vec3 normalNormalSpace = vec3(normalData.xy, sqrt(1.0 - dot(normalData.xy, normalData.xy)));

    vec3 worldGeoNormal = mat3(gbufferModelViewInverse) * geoNormal;
    vec3 worldTangent = mat3(gbufferModelViewInverse) * tangent.xyz;

    mat3 tbn = tbnNormalTangent(worldGeoNormal, tangent.rgb);
    vec3 normalWorldSpace = tbn * normalNormalSpace;
    vec3 shadowLightDirection = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);
    vec3 lightColor = pow(texture(lightmap, lightMapCoords).rgb, vec3(2.2)); // linear -> gamma

    vec4 specularData = texture(specular, texCoord);
    float perceptualSmoothness = specularData.r;
    float roughness = pow(1 - perceptualSmoothness, 2.0);
    float metallic = 0.0;
    float ambientLight = 0.2;
    vec3 reflectance;
    vec3 fragFeetPlayerSpace = (gbufferModelViewInverse * vec4(viewSpacePosition, 1.0)).xyz;
    vec3 fragWorldSpace = fragFeetPlayerSpace + cameraPosition;
    vec3 viewPosition = normalize(cameraPosition - fragWorldSpace);

    vec3 reflectionDirection = reflect(-shadowLightDirection, normalWorldSpace);
    if(specularData.g * 255 > 229){
        metallic = 1.0;
        reflectance = albedo;
    }else{
        reflectance = vec3(specularData.g);
    }
    vec3 outputColor = albedo * ambientLight + brdf(shadowLightDirection, viewPosition, roughness, normalWorldSpace, albedo, metallic, reflectance, false, false);
    //light
    float smoothness = 1 - roughness;
    float shininess = (1 + (smoothness) * 100);
    float specularLight = clamp(smoothness * pow(max(dot(reflectionDirection, viewPosition), 0.0), shininess),0.0, 1.0);
    float diffuseLight = max(dot(normalWorldSpace, shadowLightDirection), 0.0);
    float lightBrightness = ambientLight + diffuseLight + specularLight;

    outputColor *= lightBrightness;
    return outputColor;
}