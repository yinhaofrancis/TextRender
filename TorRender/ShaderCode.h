#pragma once

const char* VertexPlantShader = "#version 300 es\n"
"precision highp float;\n"
"layout(location = 0) in vec4 a_position; \n"
"layout(location = 1) in vec2 a_uv;"
"out vec2 uv;"
"void main() {\n"
"    gl_Position = a_position;\n"
"    uv = a_uv;"
"}";


const char* FragmentFormatShader = "#version 300 es\n"
"precision highp float;\n"
"uniform vec3 iResolution;\n"
"uniform float iTime;\n"
"%@\n"
"in vec2 uv;"
"layout(location = 0) out vec4 fragColor; \n"
"%@\n"
"void main() {\n"
"mainImage(fragColor,uv * iResolution.xy);\n"
"}";
