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
    return ray
}

Ray reflect(Ray ray,vec3 normal,vec3 color){
    
}