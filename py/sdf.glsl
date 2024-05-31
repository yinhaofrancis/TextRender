
float sdCircle(vec2 p,float r){
    return length(p) - r;
}
float sdBox( in vec2 p, in vec2 b)
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}
float sdRoundedBox( in vec2 p, in vec2 b, in vec4 r)
{
    r.xy = (p.x>0.0)?r.xy : r.zw;
    r.x  = (p.y>0.0)?r.x  : r.y;
    vec2 q = abs(p)-b+r.x;
    return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
}

float sdSegment(vec2 p,vec2 a, vec2 b){
    vec2 pa = p - a;
    vec2 ba = b - a;
    float h = clamp(dot(pa,ba)/dot(ba,ba),0.,1.);
    return length(pa - ba * h);
}

vec2 sdCenter(vec2 center,vec2 uv){
    return uv - center;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = 2. * (fragCoord - vec2(iResolution.x / 2.,iResolution.y / 2.)) / min(iResolution.x,iResolution.y);
    // float v = sdCircle(vec2(0),0.4,uv);
    vec2 p = sdCenter(vec2(0.5,0.9),uv);
    // float v = sdBox(p,vec2(0.5,0.6));
    float v = sdSegment(uv,vec2(0),vec2(1));



    // ;
    v = clamp(1.,0.,v);
    v = v > fwidth(uv.x) ? 1. : 0.;
    fragColor = vec4(v,v,v,1.);
}