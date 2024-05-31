
struct ray{
    vec3 location;
    vec3 direction;
    vec3 e;
};
struct camera{
    mat3 camMatric;
    vec3 location;
    float length;
};

struct squere{
    vec3 center;
    float radius;
    int roughness;
    bool metal;
    vec3 diffuse;
};

vec2 fixuv(vec2 fragCoord){
    return fragCoord / iResolution.xy;
}

vec3 hitPoint(float t,ray r){
    return r.location + t * r.direction;
}
camera createCamera(vec3 location,vec3 direction,vec3 up,float length){
    vec3 cz = normalize(direction  - location);
    vec3 cx = normalize(cross(up,cz));
    vec3 cy = normalize(cross(cz,cx));
    mat3 cc = mat3(cx,cy,cz);
    camera c;
    c.camMatric = cc;
    c.length = length;
    c.location = location;
    return c;
}

ray createRay(camera c,vec2 uv,vec2 viewPort){
    vec3 screenxy = vec3((uv * 2.- 1.) * (viewPort / 2.),c.length);
    vec3 direction = c.camMatric * screenxy;
    ray r;
    r.location = c.location;
    r.direction = normalize(direction);
    return r;
}

float squere_hit(squere sq,ray r,out vec3 first_root,out vec3 normal){
    float a = dot(r.direction,r.direction);
    float b = dot(-2. * r.direction,sq.center - r.location);
    float c = dot(sq.center - r.location,sq.center - r.location) - sq.radius * sq.radius;
    float discriminant = (b * b - 4. * a * c);
    if(discriminant < 0.){
        return 99999999.;
    }
    
    float t1 = (-b + sqrt(discriminant)) / (2.0 * a);
    float t2 = (-b - sqrt(discriminant)) / (2.0 * a);
    if(t1 > 0. && t2 > 0.){
        first_root = hitPoint(min(t1,t2),r);
        normal = normalize(first_root - sq.center);
        return min(t1,t2);
    }else{
        return -1.;
    }
}

#define COUNT 3

float hit_obj(ray r,squere sqs[COUNT],out vec3 root,out vec3 normal){
    
    
    vec3 roots[COUNT];
    vec3 normals[COUNT];

    float t[COUNT];
    int minindex = 0;
    for (int i = 0; i < COUNT; i++){
        t[i] = squere_hit(sqs[i],r,roots[i],normals[i]);
    }
    minindex = 0;
    
    for (int i = 0; i < COUNT ;i++){
        if(t[minindex] > t[i]){
            minindex = i;
        }
    }
    if(minindex < 0){
        return -1.;
    }
    root = roots[minindex];
    normal = normals[minindex];

    return t[minindex];

}
vec4 ray_tracing_scene(vec2 uv){

    camera c = createCamera(vec3(0,0,8),vec3(0,0,0),vec3(0,1,0),1.);
    vec2 vp = iResolution.xy / min(iResolution.x,iResolution.y);
    float x = 2. * cos(iTime);
    float z = 2. * sin(iTime);
    squere sqs[COUNT];
    sqs[0].center = vec3(0,-30,0);
    sqs[0].radius = 29.5;

    sqs[1].center = vec3(x,0,z);
    sqs[1].radius = 1.;

    sqs[2].center = vec3(-x,0,-z);
    sqs[2].radius = 1.;

    ray r = createRay(c,uv,vp);
    vec3 root,normal;
    float t = hit_obj(r,sqs,root,normal);
    if(t > 0.){
        
        return vec4((normal + 1.) / 2.,1.);
    }else{
        return vec4(0);
    }
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    vec2 uv = fixuv(fragCoord);
    fragColor = ray_tracing_scene(uv);
}