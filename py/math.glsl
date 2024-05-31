vec2 uvfix(vec2 fragCoord,vec2 viewPort){
    return  (fragCoord / iResolution.xy + vec2(-0.5)) * viewPort;
}

vec2 grid(vec2 fragCoord){
    return smoothstep(vec2(0.),vec2(fwidth(fragCoord)),abs(mod(fragCoord - 0.5,vec2(1)) - 0.5)); 
}
vec2 axis(vec2 fragCoord){
    return smoothstep(vec2(0.),vec2(fwidth(fragCoord)),abs(fragCoord));
}

float linem(vec2 point1,vec2 point2,vec2 fragCoord){
    float A = point2.y - point1.y;
    float B = point1.x - point2.x;
    float C = (point2.y - point1.y) * point1.x - (point2.x - point1.x) * point1.y;
    float d = abs(A * fragCoord.x + B * fragCoord.y + C) / sqrt(A*A +B*B);
    float step =  max(fwidth(fragCoord.x),fwidth(fragCoord.y));
    return smoothstep(0.0,step,d);
}
float line(vec2 a,vec2 b,vec2 fragCoord){
    vec2 ba = b - a;
    vec2 fa = fragCoord - a;
    float proj = clamp(dot(fa,ba) / dot(ba,ba),0.,1.);
    float d = length(proj * ba  - fa);
    float w = max(fwidth(fragCoord).x,fwidth(fragCoord).y) * 2.;
    return smoothstep(w,0.,d);
}
float sinplot(float a,float t,float w,vec2 fragCoord){

    float step = max(fwidth(fragCoord).x,fwidth(fragCoord).y);
    float ret = 0.;
    for(float idx = -step ;idx < step;idx += (fwidth(fragCoord.x))){
        float x1 = fragCoord.x + idx;
        float x2 = fragCoord.x + idx + 0.01;
        float y1 = a * sin(t * (x1) + w) - fragCoord.y;
        float y2 = a * sin(t * (x2) + w) - fragCoord.y;
        ret += line(vec2(x1,y1),vec2(x2,y2),fragCoord);
    }
    return clamp(0.,1.,ret);
}



float func(vec2 fragCoord){
    float t = sin(iTime);
    return sinplot(1.,t,0.,fragCoord);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = uvfix(fragCoord,vec2(10,10));
    vec2 v = grid(uv);
    float vv = min(v.x,v.y);
    if(vv < 0.9){
        fragColor =  vec4(0.3,0.3,0.3,1.);
    }
    
    vec2 ax = axis(uv);
    float aa = min(ax.x,ax.y);
    if(aa < 0.9){
        fragColor = vec4(1,1,1,1);
    }

    float bb = func(uv);
    if(bb > 0.1){
        fragColor =  mix(fragColor,vec4(bb,0.,0.,bb),bb);
    }
}