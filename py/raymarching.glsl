
float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}
float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float opSmoothUnion( float d1, float d2, float k )
{
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}


float opSmoothSubtraction( float d1, float d2, float k )
{
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h);
}

vec3 createRayDirection(vec2 fragCoord,float length,vec3 up,vec3 location,vec3 target){
    vec3 z = normalize(target - location);
    vec3 x = normalize(cross(up,z));
    vec3 y = normalize(cross(z,x));
    mat3 m = mat3(x,y,z);
     vec2 vp = iResolution.xy / min(iResolution.x,iResolution.y);
    return m * vec3(((fragCoord / iResolution.xy) * 2.0 - 1.0)* vp,length);
}


vec3 lambert(vec3 normal,vec3 lightDirection,vec3 eye){
    vec3 halfv = normalize(-eye + -lightDirection);
    float specular = pow(max(dot(halfv,normal),0.),128.);
    return pow((max(dot(normal,-lightDirection),0.01) + specular),0.55) * vec3(1,1,1);
}
vec3 opRepetition( in vec3 p, in vec3 s,float l)
{
    return p - s*clamp(round(p/s),-l,l);
    
}
float map_world(vec3 uv){
    vec3 p = uv;
    float f1 = sdBox(p,vec3(0.7,0.7,0.7));
    float f2 = sdSphere(p,1.0);
    return opSmoothUnion(f2,f1,0.1);
}

vec3 make_normal(vec3 pos){
    vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
    return normalize( e.xyy*map_world( pos + e.xyy ) + 
					  e.yyx*map_world( pos + e.yyx ) + 
					  e.yxy*map_world( pos + e.yxy ) + 
					  e.xxx*map_world( pos + e.xxx ));
}

vec3 ray_marching(vec3 ro,vec3 rd,vec3 ld) {
    float total_distance = 0.0;
    const int number_of_step = 10000;
    const float min_hit_dis = 0.0001;
    const float max_distance = 1000.;
    for (int i = 0; i < number_of_step; i++){
        vec3 current_postion = ro + total_distance * rd;
        float close_distance = map_world(current_postion);
        if(close_distance < min_hit_dis){
            return lambert(make_normal(current_postion),normalize(ld),normalize(current_postion - ro));
        }else if(close_distance > max_distance){
            break;
        }
        total_distance += close_distance;
    }
    return vec3(0.0);
}




void mainImage(out vec4 fragColor, in vec2 fragCoord){
    float x = 2.0 * cos(iTime * 0.5);
    float z = 2.0 * sin(iTime * 0.5);
    vec3 ro = vec3(x,1,z);
    vec3 rd = createRayDirection(fragCoord,0.7,vec3(0,1,0),ro,vec3(0,0,0));

    

    fragColor = vec4(ray_marching(ro,rd,vec3(-5,-5,5)),1);
}