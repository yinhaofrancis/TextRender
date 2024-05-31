//
//  Toy.h
//  TorRender
//
//  Created by FN-540 on 2024/5/30.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface Toy : NSObject
@property(nonatomic,nullable) CAEAGLLayer* layer;
- (instancetype)initWithShader:(NSString*)shader textureCode:(NSArray<NSString *> *)code;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (void)addTexture2d:(UIImage *)image uniform:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
