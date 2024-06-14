
struct ray{
    vec3 ro;
    vec3 rd;
};

struct camera{
    vec3 co;
    mat3 md;
    float length;
    float ratio;
};

camera make_camera_by_look_at(vec3 co,vec3 center,vec3 up,float length,float ratio){
    vec3 z = normalize(co - center);
    vec3 x = normalize(cross(up,z));
    vec3 y = normalize(cross(z,x));
    mat3 m = mat3(x,y,z);
    camera c;
    c.co = co;
    c.md = m;
    c.ratio = ratio;
    c.length = length;
    return c;
}

ray make_ray(camera c,vec2 uv){
    uv = uv * 2.0 - 1.0;
    uv.x = uv.x * c.ratio;
    vec3 pScreen = normalize(vec3(uv,-c.length));
    vec3 rd = normalize(c.md * pScreen);
    ray r;
    r.rd = rd;
    r.ro = c.co;  
    return r;
}

vec3 ray_func(ray r,float t){
    return r.ro + r.rd * t;
}