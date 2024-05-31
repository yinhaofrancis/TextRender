//
//  ShaderRender.hpp
//  ShaderRender
//
//  Created by FN-540 on 2024/5/29.
//

#ifndef ShaderRender_hpp
#define ShaderRender_hpp

#include <stdio.h>
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>
#include <chrono>
using namespace std::chrono;
class ShaderRender {
    
public:
    ShaderRender(const char* vertex,const char* fragment);
    ~ShaderRender();
    
    void render(int w,int h);
    
private:
    static GLuint loadShader(const char* code,GLenum type);
    static bool check(GLuint shader);
    GLuint m_program;
    GLuint m_vao;
    GLuint m_vbo;
    GLuint m_ebo;
    void createVertex();
    void loadUniformData();
    milliseconds startTime;
};

#endif /* ShaderRender_hpp */
