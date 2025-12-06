vec3 brdf(vec3 shadowLightDirection, vec3 viewPosition, float roughness, vec3 normalWorldSpace, vec3 albedo, float metallic, vec3 reflectance, bool diffuseOnly, bool reflectionPass, vec3 lightColor){
    float H = normalize(shadowLightDirection, viewPosition);
    float F0 = reflectance;
    //dot
    float VdotH = clamp(dot(viewPosition, H), 0.001, 1.0);
    float NdotH = clamp(dot(normalWorldSpace, H), 0.001, 1.0);
    float NdotV = clamp(dot(normalWorldSpace, viewPosition), 0.001, 1.0);
    float NdotL = clamp(dot(normalWorldSpace, shadowLightDirection), 0.001, 1.0);
    //Cook Torance
    float fresnelReflectance = F0 + (1 - F0) * pow(1 - VdotH, 5);
    float D = (roughness*roughness) / (3.141592653 * pow((dot(normalWorldSpace, H) * dot(normalWorldSpace, H)) * ((roughness*roughness) - 1.0) + 1.0, 2.0));
    float geometry = (NdotL / (NdotL * (1- pow(roughness, 2) / 2) + pow(roughness, 2) / 2)) * (NdotV / ((NdotV*(1 - (pow(roughness, 2) / 2)) + (pow(roughness, 2) / 2))));

    float cookTorrance = (fresnelReflectance * DFunctionDistributionGGX * geometry) / (4 * NdotV * NdotL);
    //Lambertian diffuse
    float LambertianDiffuse = albedo / 3.141592653 * max(NdotL, 0) * lightColor;
    float BRDF = (cookTorrance + LambertianDiffuse) * lightColor;
    if (diffuseOnly){
        BRDF = LambertianDiffuse;
    }else if(reflectionPass){
        BRDF = cookTorrance;
    }
    return brdf;
}