/**
* Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
* EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
* and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
*/

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <SceneKit/SceneKit.h>

@interface OpenGLView : UIView

@property(nonatomic, strong) CAEAGLLayer * eaglLayer;
@property(nonatomic, strong) EAGLContext *context;
@property(nonatomic) GLuint colorRenderBuffer;
@property(nonatomic) SCNMatrix4 cameraview4Matrix;
@property(nonatomic) SCNMatrix4 projection4Matrix;
- (void)start;
- (void)stop;
- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation;
- (void)setOrientation:(UIInterfaceOrientation)orientation;

@end
