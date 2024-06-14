struct Ray{
    vec3 location;
    vec3 direction;
    vec3 color;
};

struct Material{
    bool metal;
    float roughness;
    vec3 color;
};

float opUnion( float d1, float d2 )
{
    return min(d1,d2);
}

mat3 lookAtDirection(vec3 ro, vec3 rt,vec3 cu){
    vec3 z = ro - rt;
    vec3 x = cross(cu,z);
    vec3 y = cross(z,x);

    return mat3(x,y,z);
}

Ray createRay(vec2 uv,float length,vec3 ro,vec3 rt,vec3 cu){
    mat3 lookat = lookAtDirection(ro,rt,cu);
    vec3 target = vec3(uv,length);
    vec3 direction = lookat * target;
    Ray ray;
    ray.location = ro;
    ray.direction = direction;
    ray.color  = vec3(1);
    return ray;
}
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
vec3 random(vec3 point){
    float x = random(point.yz);
    float y = random(point.xz);
    float z = random(point.xy);
    vec3 m = vec3(x,y,z);
    return length(m) > 1. ? normalize(m) : m;
}

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}
vec3 sdCenter(vec3 p, vec3 c){
    return p + c;
}
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
float sdWorld(vec3 p){
    float f1 = sdSphere(p,0.5); 
    float f2 = sdBox(sdCenter(p,vec3(0,-0.5,0)),vec3(5.,0.1,5.));
    float f3 = opUnion(f1,f2);
    return f3;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){

}