float generate1(vec2 uv){
    float time = fract(iTime);
    float start = sin(-dot(uv,vec2(34,-39)));
    float value = start;
    value = fract(value * time * 4234.4234);
    return value;
}
float generate2(vec2 uv){
    float time = fract(iTime);
    float start = sin(-dot(uv,vec2(52,-39)));
    float value = start;
    value = fract(value * time * 5347.4234);
    return value;
}
float generate3(vec2 uv){
    float time = fract(iTime);
    float start = sin(-dot(uv,vec2(34,-39)));
    float value = start;
    value = fract(value * time * 5347.4234);
    return value;
}
float generate(vec2 uv){
    float time = fract(iTime);
    float start = sin(dot(uv,vec2(generate1(uv),generate2(uv))));
    float value = start;
    value = fract(value * time * 5447.4234);
    return abs(value);
}

float cirlce(float radius,vec2 center,vec2 fragCoord,vec2 offset){
    float b = generate(fragCoord);
    float dist = distance(fragCoord,center) + 10.0 * sin(0.05 * fragCoord.x * offset.x) * cos(0.05 * fragCoord.y * offset.y);
    
    return smoothstep(radius+0.02,radius-0.02,dist);
}

vec2 generateStatic(vec2 uv){
    return sin(uv * 3.145926);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = floor(iMouse.xy/iResolution.xy);
    // float v = cirlce(200.0,vec2(300,300),fragCoord,generateStatic(uv));
    float v = generate(uv);
    fragColor =  vec4(v,v,v,1.0);
    fwidth(fragColor.x);
}

