#define numOctaves 8


float hash( int n ) 
{
	n = (n << 13) ^ n;
    n = n * (n * n * 15731 + 789221) + 1376312589;
    return -1.0+2.0*float( n & ivec3(0x0fffffff))/float(0x0fffffff);
}

// gradient noise
float gnoise( in float p )
{
    int   i = int(floor(p));
    float f = fract(p);
    float u = f*f*(3.0-2.0*f);
    return mix( hash(i+0)*(f-0.0), 
                hash(i+1)*(f-1.0), u);
}


float fbm( in float x, in float H )
{    
    float G = exp2(-H);
    float f = 1.0;
    float a = 1.0;
    float t = 0.;
    for( int i=0; i<numOctaves; i++ )
    {
        t += a*gnoise(f*x);
        f *= 2.0;
        a *= G;
    }
    return t;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 uv = fragCoord / iResolution.xy;
    vec2 k = iMouse.xy / iResolution.xy;
    float v = (fbm(uv.x,k.x) + 10.) / 18.;
    if (uv.y < v){
        fragColor = vec4(1,1,0,1);
    }else{
        fragColor = vec4(0);
    }
}

