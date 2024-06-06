#iChannel0 "file://noise.png"

void mainImage( out vec4 fragColor, in vec2 fragCoord ){

    vec2 uv = fragCoord / iResolution.xy;
    uv = reflect(normalize(-uv),normalize(vec2(1,1)));
    fragColor = vec4(uv,0,1);
}