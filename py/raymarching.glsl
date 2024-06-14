
float dot2( in vec2 v ) { return dot(v,v); }
float dot2( in vec3 v ) { return dot(v,v); }
float ndot( in vec2 a, in vec2 b ) { return a.x*b.x - a.y*b.y; }
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
float opUnion( float d1, float d2 )
{
    return min(d1,d2);
}
float opSubtraction( float d1, float d2 )
{
    return max(-d1,d2);
}
float opIntersection( float d1, float d2 )
{
    return max(d1,d2);
}
float opXor(float d1, float d2 )
{
    return max(min(d1,d2),-max(d1,d2));
}

vec3 createRayDirection(vec2 fragCoord,float length,vec3 up,vec3 location,vec3 target){
    vec3 z = normalize(target - location);
    vec3 x = normalize(cross(up,z));
    vec3 y = normalize(cross(z,x));
    mat3 m = mat3(x,y,z);
     vec2 vp = iResolution.xy / min(iResolution.x,iResolution.y);
    return m * normalize(vec3(((fragCoord / iResolution.xy) * 2.0 - 1.0)* vp,length));
}


vec3 lambert(vec3 normal,vec3 lightDirection,vec3 eye){
    vec3 halfv = normalize(-eye + -lightDirection);
    float specular = pow(max(dot(halfv,normal),0.),128.);

    vec3 rf = reflect(normalize(lightDirection),normalize(normal));
    float specular2 = pow(max(dot(normalize(-eye),normalize(rf)),0.),128.);

    return pow((max(dot(normal,-lightDirection),0.01) + specular),0.55) * vec3(1,1,1);
}
vec3 opRepetition( in vec3 p, in vec3 s,float l)
{
    return p - s*clamp(round(p/s),-l,l);
    
}
float sdPlane( vec3 p, vec3 n, float h )
{
  // n must be normalized
  return dot(p,n) + h;
}
float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
float sdHexPrism( vec3 p, vec2 h )
{
  const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
  p = abs(p);
  p.xy -= 2.0*min(dot(k.xy, p.xy), 0.0)*k.xy;
  vec2 d = vec2(
       length(p.xy-vec2(clamp(p.x,-k.z*h.x,k.z*h.x), h.x))*sign(p.y-h.x),
       p.z-h.y );
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
float udQuad( vec3 p, vec3 a, vec3 b, vec3 c, vec3 d )
{
  vec3 ba = b - a; vec3 pa = p - a;
  vec3 cb = c - b; vec3 pb = p - b;
  vec3 dc = d - c; vec3 pc = p - c;
  vec3 ad = a - d; vec3 pd = p - d;
  vec3 nor = cross( ba, ad );

  return sqrt(
    (sign(dot(cross(ba,nor),pa)) +
     sign(dot(cross(cb,nor),pb)) +
     sign(dot(cross(dc,nor),pc)) +
     sign(dot(cross(ad,nor),pd))<3.0)
     ?
     min( min( min(
     dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
     dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
     dot2(dc*clamp(dot(dc,pc)/dot2(dc),0.0,1.0)-pc) ),
     dot2(ad*clamp(dot(ad,pd)/dot2(ad),0.0,1.0)-pd) )
     :
     dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}
float map_world(vec3 uv){
    vec3 p = uv;
    float f1 = sdBox(sdCenter(uv,vec3(0.,2.,0.)),vec3(10.,0.01,10.));

    float f3 = sdBox(sdCenter(uv,vec3(0.,-1.5,0.)),vec3(3.5,1.5,1.5));
    
    float f2 = sdSphere(p,2.);

    float f4 = opSmoothUnion(f3,f2,0.1);
    return opUnion(f1,f4);

    // return 
    // return f1;
}

vec3 make_normal(vec3 pos){
    vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
    return normalize( e.xyy*map_world( pos + e.xyy ) + 
					  e.yyx*map_world( pos + e.yyx ) + 
					  e.yxy*map_world( pos + e.yxy ) + 
					  e.xxx*map_world( pos + e.xxx ));
}


float ray_marching_shadow(vec3 ro,vec3 rd) {

    float total_distance = 0.0;
    const int number_of_step = 1000;
    const float min_hit_dis = 0.00001;
    const float max_distance = 100.;
    for (int i = 0; i < number_of_step; i++){
        vec3 current_postion = ro + total_distance * rd;
        float close_distance = map_world(current_postion);
        if(close_distance < min_hit_dis){
            vec3 normal = make_normal(current_postion);
            if(dot(normalize(normal),normalize(rd)) < 0.){
                return 0.;
            }else{
                break;
            }
        }
        else if(close_distance > max_distance){
            break;
        }
        total_distance += close_distance;
    }
    return 1.;
}

vec3 ray_marching(vec3 ro,vec3 rd,vec3 ld) {
    float total_distance = 0.0;
    const int number_of_step = 1000;
    const float min_hit_dis = 0.0001;
    const float max_distance = 1000.;
    for (int i = 0; i < number_of_step; i++){
        vec3 current_postion = ro + total_distance * rd;
        float close_distance = map_world(current_postion);
        if(close_distance < min_hit_dis){
            vec3 normal = make_normal(current_postion);
            float shadow = ray_marching_shadow(current_postion,normalize(-ld));
            vec3 color = lambert(normal,normalize(ld),normalize(current_postion - ro));
            return shadow * color; 

        }else if(close_distance > max_distance){
            break;
        }
        total_distance += close_distance;
    }
    return vec3(0.0);
}





void mainImage(out vec4 fragColor, in vec2 fragCoord){
    float x = 6.0 * cos(iTime);
    float z = 6.0 * sin(iTime);
    vec3 ro = vec3(x,1.5,z);
    vec3 rd = createRayDirection(fragCoord,1.,vec3(0,1,0),ro,vec3(0,0,0));

    

    fragColor = vec4(ray_marching(ro,rd,vec3(-5,-5,5)),1);
}