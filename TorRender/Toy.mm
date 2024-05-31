//
//  Toy.m
//  TorRender
//
//  Created by FN-540 on 2024/5/30.
//

#import "Toy.h"
#import "ShaderCode.h"
#import "ShaderRender.hpp"
#import <UIKit/UIKit.h>


static EAGLContext* ctx;

@interface Toy (){
    ShaderRender* sr;
    NSThread* thread;
    NSRunLoop *runloop;
    CADisplayLink* link;
    bool isClose;
    GLuint framebuffer,renderbuffer;
    NSMutableArray<NSString*>*texture;
}

@end

@implementation Toy

- (instancetype)initWithShader:(NSString*)shader textureCode:(NSArray<NSString *> *)code
{
    self = [super init];
    if (self) {
        sr = nullptr;
        framebuffer = 0;
        renderbuffer = 0;
        runloop = nil;
        thread = nil;
        isClose = false;
        texture = [[NSMutableArray alloc] init];
        NSLock *l = [[NSLock alloc] init];
        [l lock];
        
        thread = [[NSThread alloc] initWithBlock:^{
            if(ctx == nil){
                ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
                
            }
            [EAGLContext setCurrentContext:ctx];
            NSString * texture = [code componentsJoinedByString:@"\n"] ?: @"";
            NSString* format = [NSString stringWithCString:FragmentFormatShader encoding:NSUTF8StringEncoding];
            const char *code = [[NSString stringWithFormat:format,texture,shader] cStringUsingEncoding:NSUTF8StringEncoding];
            self->runloop = [NSRunLoop currentRunLoop];
            self->sr = new ShaderRender(VertexPlantShader,code);
            [l unlock];
            self->link = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawCall)];
            [self->link addToRunLoop:self->runloop forMode:NSDefaultRunLoopMode];
            [self->runloop run];
        }];
        thread.name = @"render";
        [thread start];
        [l lock];
    }
    return self;
}
-(void)drawCall{
    if(isClose){
        [link invalidate];
        [thread cancel];
        CFRunLoopStop(runloop.getCFRunLoop);
        delete sr;
        return;
    }else{
        if (self.layer != nil){
            [EAGLContext setCurrentContext:ctx];
            glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
            CGFloat w = self.layer.frame.size.width * self.layer.contentsScale;
            CGFloat h = self.layer.frame.size.height * self.layer.contentsScale;
            sr->render(int(w),int(h));
            [ctx presentRenderbuffer:GL_RENDERBUFFER];
        }
    }
}
- (void)setLayer:(CAEAGLLayer *)layer{
    _layer = layer;
    [self->runloop performBlock:^{
        [EAGLContext setCurrentContext:ctx];
        GLuint framebuffer = self->framebuffer;
        GLuint renderbuffer = self->renderbuffer;
        if(framebuffer > 0){
            glDeleteBuffers(1, &framebuffer);
            glDeleteBuffers(1, &renderbuffer);
        }
        glGenFramebuffers(1, &framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        glGenRenderbuffers(1, &renderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, renderbuffer);
        [ctx renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.layer];
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, renderbuffer);
        GLenum m = glCheckFramebufferStatus(GL_FRAMEBUFFER);
        if (m != GL_FRAMEBUFFER_COMPLETE){
            printf("%s","framebuffer fail");
        }else{
            self->framebuffer = framebuffer;
            self->renderbuffer = renderbuffer;
        }
       
        
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
    }];
}
- (void)addTexture:(NSString *)type name:(NSString *)name{
    [texture addObject:[NSString stringWithFormat:@"uniform %@ %@;",type,name]];
}
- (void)dealloc
{
    [EAGLContext setCurrentContext:ctx];
    GLuint framebuffer = self->framebuffer;
    GLuint renderbuffer = self->renderbuffer;
    if(framebuffer > 0){
        glDeleteBuffers(1, &framebuffer);
        glDeleteBuffers(1, &renderbuffer);
    }
}
@end
