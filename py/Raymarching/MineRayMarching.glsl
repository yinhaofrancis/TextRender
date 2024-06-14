
#include "sdfModel.glsl"
#include "ray.glsl"

float sdWorld(vec3 p){
    float f1 = sdSphere(p,0.5); 
    float f2 = sdBox(sdCenter(p,vec3(0,-0.5,0)),vec3(5.,0.1,5.));
    float f3 = opUnion(f1,f2);
    return f3;
}
vec3 sdNormal(vec3 pos){
    vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
    return normalize( e.xyy*sdWorld( pos + e.xyy ) + 
					  e.yyx*sdWorld( pos + e.yyx ) + 
					  e.yxy*sdWorld( pos + e.yxy ) + 
					  e.xxx*sdWorld( pos + e.xxx ));
}

float sdRayMarching(ray r){
    float t = 0.;
    float min_hit_distance = 0.000001;
    int max_step = 1000;
    float max_distance = 100000.;

    for (int i = 0;i < max_step; i++){
        vec3 current_point = ray_func(r,t);
        float current_distance = sdWorld(current_point);
        if(current_distance < min_hit_distance){
            return t;
        }
        if(current_distance > max_distance){
            break;
        }
        t += current_distance;
    }
    return -1.;
}


float shadow( vec3 hitPoint,vec3 ld, float mint, float maxt)
{

    ray r;
    r.ro = hitPoint;
    r.rd = normalize(-ld);
    float t = mint;
    for( int i=0; i<30 && t<maxt; i++ )
    {
        vec3 p = ray_func(r,t);
        float h = sdWorld(p);

        if( h<0.0000001)
            return 0.0;

        t += h;
    }
    return 1.;
}

float sdRayMarchingShadow(vec3 hitPoint,vec3 ld){
    return shadow(hitPoint,ld,0.02,10.);
}


float lambert(vec3 ld,vec3 normal){
   return max(dot(normalize(-ld),normal),0.);
}
float blinPhone(vec3 ld,vec3 normal,vec3 cd){
    vec3 halfv = normalize(normalize(-ld) + normalize(-cd));
    return pow(max(dot(normalize(normal),halfv),0.),128.);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    vec2 uv = fragCoord / iResolution.xy;
    vec3 location = vec3(3. * sin(iTime * 0.3),2,3. * cos(iTime * 0.3));
    camera c = make_camera_by_look_at(
        location,
        vec3(0,0,0),
        vec3(0,1,0)
        ,1.,iResolution.x / iResolution.y);

    ray r = make_ray(c,uv);
    float ret = sdRayMarching(r);

    if(ret > 0.) {
        
        vec3 hitp = ray_func(r,ret);
        vec3 lp = vec3 (5,5,5);
        // vec3 ld = vec3(-1,-1,-1);
        vec3 ld = hitp - lp;

        vec3 normal = sdNormal(hitp);
        float diffuse = lambert(ld,normal);
        float specular  = blinPhone(ld,normal,r.rd);
        float shadow = sdRayMarchingShadow(hitp,ld);
        vec3 color = vec3(1.,1.,1.) * (specular + diffuse) * shadow;
        
        fragColor = vec4(color,1.);
        // fragColor = vec4(shadow);
    }
}
