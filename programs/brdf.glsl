vec3 brdf(vec3 shadowLightDirection, vec3 viewPosition, float roughness, vec3 normalWorldSpace, vec3 albedo, float metallic, vec3 reflectance, bool diffuseOnly, bool reflectionPass){
    float alpha = pow(roughness, 2);

    vec3 H = normalize(shadowLightDirection + viewPosition);

    //dot
    float NdotV = clamp(dot(normalWorldSpace, viewPosition), 0.001, 1.0);
    float NdotL = clamp(dot(normalWorldSpace, shadowLightDirection), 0.001, 1.0);
    float NdotH = clamp(dot(normalWorldSpace, H), 0.001, 1.0);
    float VdotH = clamp(dot(viewPosition, H), 0.001, 1.0);

    //Schlick's approximation
    vec3 fresnelReflectance = reflectance + (1.0 - reflectance) * pow(1.0 - VdotH, 5.0);

    //phong diffuse
    albedo *= (vec3(1.0) - fresnelReflectance);
    albedo *= (1 - metallic);

    float k = alpha / 2;
    float geometry = (NdotL / (NdotL * (1 - k)) * (NdotV / (NdotV * (1 - k)+ k)));

    float lowerTerm = pow(NdotH, 2) * (pow(alpha, 2) - 1.0) + 1.0;
    float normalDistibutionFunctionGXX = pow(alpha, 2) / (3.14159 * pow(lowerTerm, 2));

    vec3 cookTorrace = (fresnelReflectance * normalDistibutionFunctionGXX * geometry) / (4 * NdotL * NdotV);
    vec3 Brdf = (albedo + cookTorrace) * NdotL;

    if(diffuseOnly){
        Brdf = (albedo) * NdotL;
    }
    if(reflectionPass){
        Brdf = fresnelReflectance;
    }
    return Brdf;
}