vec3 BRDF(vec3 shadowLightDirection, vec3 viewPosition, float roughness, vec3 normalWorldSpace, vec3 albedo, float metallic, vec3 reflectance, bool diffuseOnly, bool reflectionPass, vec3 lightColor){
    float k = pow(roughness, 2) / 2;
    vec3 F0 = reflectance;
    vec3 H = normalize(viewPosition + shadowLightDirection);
    
    //dot
    float VdotH = clamp(dot(viewPosition, H), 0.001, 1.0);
    float NdotH = clamp(dot(normalWorldSpace, H), 0.001, 1.0);
    float NdotV = clamp(dot(normalWorldSpace, viewPosition), 0.001, 1.0);
    float NdotL = clamp(dot(normalWorldSpace, shadowLightDirection), 0.001, 1.0);
    
    //Cook Torance
    vec3 fresnelReflectance = F0 + (1 - F0) * pow(1 - VdotH, 5);
    float DFunctionDistributionGGX = pow(roughness, 2) / (3.141592653 * pow((dot(normalWorldSpace, H) * dot(normalWorldSpace, H)) * (pow(roughness, 2) - 1.0) + 1.0, 2.0));
    float geometry = (NdotL / (NdotL*(1-k)+k)) * (NdotV / ((NdotV*(1-k)+k)));
    vec3 cookTorrance = (fresnelReflectance * DFunctionDistributionGGX * geometry) / (4 * NdotV * NdotL);
    
    //Lambertian diffuse
    vec3 LambertianDiffuse = albedo / 3.141592653 * max(NdotL, 0) * lightColor;
    
    //Additional light color
    vec3 BRDF = (cookTorrance + LambertianDiffuse) * lightColor;
    if (diffuseOnly){
        BRDF = LambertianDiffuse;
    }else if(reflectionPass){
        BRDF = cookTorrance;
    }
    
    return BRDF;
}