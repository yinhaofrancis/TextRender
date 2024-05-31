uvec2 pcg2d(uvec2 v)
{
    v = v * 1664525u + 1013904223u;

    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;

    v = v ^ (v>>16u);

    v.x += v.y * 1664525u;
    v.y += v.x * 1664525u;

    v = v ^ (v>>16u);

    return v;
}
vec2 pcg2d_f(vec2 v)
{
    return (1.0/float(0xffffffffu)) * vec2(pcg2d( uvec2(floatBitsToUint(v.x), floatBitsToUint(v.y)) ));
}
float random(vec2 uv){
    return fract(23294.44* sin(dot(vec2(232.423,32.8) , pcg2d_f(uv))));
}
float noise (in vec2 st) {
    st = st * 1.0;
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    // vec2 u = f*f*(3.0-2.0*f);
    vec2 u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}
float sdCircle(vec2 p,float r){
    return length(p) - r;
}

float sdWorld(vec2 p){
    float x = sin(iTime);
    float y = cos(iTime);
    vec2 offset = vec2(x,y);
    return sdCircle(p,noise(p + offset));
}

#define PI 3.14159265
vec2 normal_distribution(vec2 uv,vec2 r,vec2 m){
    vec2 a = 1.0 / (r * sqrt(2. * PI));
    vec2 expv = (uv - m) * (uv - m) / (2. * r * r) * -1.;
    return exp(expv) * a;
}
float normal_distribution(float uv,float r,float m){
    float a = 1.0 / (r * sqrt(2. * PI));
    float expv = (uv - m) * (uv - m) / (2. * r * r) * -1.;
    return exp(expv) * a;
}
#iChannel0 "file://6c6515466de37629f9b67a959c6c8ed5.jpeg"
void radiam_image(out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = ((fragCoord / iResolution.xy) * 2.0 - 1.0) * (iResolution.xy / min(iResolution.x,iResolution.y));
    float v = 1. - smoothstep(0.,1.,sdWorld(uv));
    fragColor = vec4(v,v,v,v);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord ){
    float radius = 6.;
    float step = 1.;
    vec4 color;
    float sump;
    for(float i = -radius;i < radius * 2.;i+= step){
        for(float j = -radius;j < radius * 2.;j+= step){
            float n = distance(vec2(i,j) + fragCoord,fragCoord);
            float p = normal_distribution(n,radius,0.);
            vec2 tuv = (vec2(i,j) + fragCoord) / iResolution.xy;
            color +=  texture(iChannel0,tuv) * p;
            sump += p;
        }
    }
    fragColor = color / sump;
}