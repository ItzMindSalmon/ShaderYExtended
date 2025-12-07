uniform sampler2D gtexture;

/* DRAWBUFFERS: 0 */
layout(location = 0) out vec4 outColor0;

in vec3 foliageColor;
in vec2 texCoord;
in vec2 lightMapCoords;

void main(){
    vec4 outputColorData = pow(texture(gtexture, texCoord), vec4(2.2));
    vec3 outputColor = pow(outputColorData.rgb, vec3(2.2)) * pow(foliageColor, vec3(2.2));

    // remove the color thing behind grasses and flowers
    float transparency = outputColorData.a;
    if(transparency < .1){
        discard;
    }

    //output
    outColor0 = pow(vec4(pow(outputColor, vec3(1 / 2.2)), transparency), vec4(1 / 2.2)); // gamma -> linear
}