#iChannel0 "file://noise.png"


vec2 complex_square( vec2 v) {
	return vec2(
		v.x * v.x - v.y * v.y,
		v.x * v.y * 2.0
	);
}
vec2 julia(vec2 z,vec2 c){
    return complex_square(z) + c;
}

float juliaSet(vec2 z,vec2 c){
    float step = 100.;
    vec2 r = z;
    float idx = 0.;
    for(float i = 0.; i < step; i += 1.){
        r = julia(r,c);
        float l = length(r);
        if(l > 2.){
            idx = i;
        }
    }
    float a = 1. / step * pow(idx,2.);
    return a;
}
vec2 ramdom(vec2 z){
    return fract(sin(z * 2352.244) * 233.74);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord ){

    vec2 uv = fragCoord.xy - iResolution.xy * 0.5;
	uv *= 4. / min( iResolution.x, iResolution.y);
    vec2 cc = (iMouse.xy / iResolution.xy);
    float x = 1.,y = 1.;
    float vv = 0.98;
    float step = 0.2;
    for (float i = 0.; i < 1.; i+=0.4){
        x *= 1.2* sin(iTime * texture(iChannel0,vec2(vv,i)).x);
        y *= 1.2 * cos(iTime * texture(iChannel0,vec2(1. - vv ,i)).x);
    }

    
    vec2 c = vec2(x,y);

    float a = juliaSet(uv,c);
    
    fragColor = mix(vec4(0),vec4(0.5,0.1,0.5,1),a);
}