//
//  ShaderRender.cpp
//  ShaderRender
//
//  Created by FN-540 on 2024/5/29.
//

#include "ShaderRender.hpp"
#include <string.h>
#include <time.h>
#include <math.h>


ShaderRender::ShaderRender(const char* vertex,const char* fragment):m_program(glCreateProgram()){
    auto vs = ShaderRender::loadShader(vertex, GL_VERTEX_SHADER);
    auto fs = ShaderRender::loadShader(fragment, GL_FRAGMENT_SHADER);
    glAttachShader(m_program, vs);
    glAttachShader(m_program, fs);
    glLinkProgram(m_program);
    glDeleteShader(vs);
    glDeleteShader(fs);
    this->createVertex();
    
    milliseconds ms = duration_cast< milliseconds >(
        system_clock::now().time_since_epoch()
    );
    startTime = ms;
}
void ShaderRender::createVertex(){
    GLuint vao;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);
    m_vao = vao;
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    float vertex [6 * 4] = {
        -1, 1, 0,1,0,1,
        -1,-1, 0,1,0,0,
         1, 1, 0,1,1,1,
         1,-1, 0,1,1,0
    };
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertex), vertex, GL_STATIC_DRAW);
    m_vbo = vbo;
    
    GLuint ebo;
    short vertexArray [6] = {
        2,0,1,2,3,1
    };
    glGenBuffers(1, &ebo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_STATIC_DRAW);
    m_ebo = ebo;
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(0, 4, GL_FLOAT, false, 6 * sizeof(float), 0);
    glVertexAttribPointer(1, 2, GL_FLOAT, false, 6 * sizeof(float), (void*)(4 * sizeof(float)));
//    glDisableVertexAttribArray(0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}
void ShaderRender::loadUniformData() {
    GLint m_viewport[4];
    glGetIntegerv(GL_VIEWPORT, m_viewport);
    auto iResolution = glGetUniformLocation(m_program, "iResolution");
    glUniform3f(iResolution, m_viewport[2], m_viewport[3], 1);
    auto iTime = glGetUniformLocation(m_program, "iTime");
    milliseconds ms = duration_cast< milliseconds >(
        system_clock::now().time_since_epoch()
    );
    float v = (ms.count() - startTime.count()) / 1000.0;
    
    glUniform1f(iTime, fmod(v,20 * M_PI));
}

void ShaderRender::render(int w,int h){
    
    glClearColor(0.f, 1.f, 0.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, w, h);
    glBindVertexArray(m_vao);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_ebo);
    glUseProgram(m_program);
    loadUniformData();
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
}
GLuint ShaderRender::loadShader(const char *code, GLenum type){
    auto v = glCreateShader(type);
    int len = (int)strlen(code);
    const GLchar *const * pcode = const_cast<const GLchar *const *>(&code);
    glShaderSource(v, 1,pcode, const_cast<const GLint*>(&len));
    glCompileShader(v);
    check(v);
    return v;
}
bool ShaderRender::check(GLuint shader){
    GLint compile = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compile);
    if(!compile){
        GLint loglen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &loglen);
        if(loglen > 1){
            char * logs = new char[loglen];
            glGetShaderInfoLog(shader, loglen, &loglen, logs);
            printf("%s",logs);
            delete [] logs;
        }
        return false;
    }
    return true;
}
ShaderRender::~ShaderRender(){
    glDeleteProgram(m_program);
    glDeleteVertexArrays(1, &m_vao);
}
