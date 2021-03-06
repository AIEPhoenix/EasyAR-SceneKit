/**
* Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
* EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
* and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
*/

#import "OpenGLView.h"
#import "AppDelegate.h"

#include <iostream>
#include "ar.hpp"
#include "renderer.hpp"

/*
* Steps to create the key for this sample:
*  1. login www.easyar.com
*  2. create app with
*      Name: HelloARVideo
*      Bundle ID: cn.easyar.samples.helloarvideo
*  3. find the created item in the list and show key
*  4. set key string bellow
*/
NSString* key = @"05GjAA2Hpfzqe5hjFBDmQdObnMHo58UrzdUtMnNDCt1JrhkZLBbUI9ZVbbDmoXsTnVBcgIMXlJQ320EBprHXEOTrSssITLmvp8W8c78c6233b150bd0670b1e5345ada28c7JFKqPOricIyrcvPVPkbyXOVOVVTIMCcDvjII37awCQPQP3G1JiJhj9FAIvMUJSad8rzX";

namespace EasyAR {
namespace samples {

class HelloARVideo : public AR
{
public:
    HelloARVideo();
    ~HelloARVideo();
    virtual void initGL();
    virtual void resizeGL(int width, int height);
    virtual void render();
    virtual bool clear();
    
    /***********/
    Matrix44F cameraview4Matrix;
    Matrix44F projection4Matrix;
    bool isTracked;//是否识别出图片
    bool shouldShowStar;//是否要显示星球模型
    /***********/
    
private:
    Vec2I view_size;
    VideoRenderer* renderer[3];
    int tracked_target;
    int active_target;
    int texid[3];
    ARVideo* video;
    VideoRenderer* video_renderer;
};

HelloARVideo::HelloARVideo()
{
    view_size[0] = -1;
    tracked_target = 0;
    active_target = 0;
    for(int i = 0; i < 3; ++i) {
        texid[i] = 0;
        renderer[i] = new VideoRenderer;
    }
    video = NULL;
    video_renderer = NULL;
}

HelloARVideo::~HelloARVideo()
{
    for(int i = 0; i < 3; ++i) {
        delete renderer[i];
    }
}

void HelloARVideo::initGL()
{
    augmenter_ = Augmenter();
    for(int i = 0; i < 3; ++i) {
        renderer[i]->init();
        texid[i] = renderer[i]->texId();
    }
}

void HelloARVideo::resizeGL(int width, int height)
{
    view_size = Vec2I(width, height);
}

void HelloARVideo::render()
{
    glClearColor(0.f, 0.f, 0.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    Frame frame = augmenter_.newFrame();
    if(view_size[0] > 0){
        int width = view_size[0];
        int height = view_size[1];
        Vec2I size = Vec2I(1, 1);
        if (camera_ && camera_.isOpened())
            size = camera_.size();
        if(portrait_)
            std::swap(size[0], size[1]);
        float scaleRatio = std::max((float)width / (float)size[0], (float)height / (float)size[1]);
        Vec2I viewport_size = Vec2I((int)(size[0] * scaleRatio), (int)(size[1] * scaleRatio));
        if(portrait_)
            viewport_ = Vec4I(0, height - viewport_size[1], viewport_size[0], viewport_size[1]);
        else
            viewport_ = Vec4I(0, width - height, viewport_size[0], viewport_size[1]);
        
        if(camera_ && camera_.isOpened())
            view_size[0] = -1;
    }
    augmenter_.setViewPort(viewport_);
    augmenter_.drawVideoBackground();
    glViewport(viewport_[0], viewport_[1], viewport_[2], viewport_[3]);

    AugmentedTarget::Status status = frame.targets()[0].status();
    if(status == AugmentedTarget::kTargetStatusTracked){
        int id = frame.targets()[0].target().id();
        if(active_target && active_target != id) {
            video->onLost();
            delete video;
            video = NULL;
            tracked_target = 0;
            active_target = 0;
        }
        /****************/
        isTracked = true;
        /****************/
        if (!tracked_target) {
            if (video == NULL) {
                
                if(frame.targets()[0].target().name() == std::string("argame") && texid[0]) {
                    video = new ARVideo;
                    video->openVideoFile("video.mp4", texid[0]);
                    video_renderer = renderer[0];
                    /****************/
                    shouldShowStar = false;
                    /****************/
                }
                else if(frame.targets()[0].target().name() == std::string("namecard") && texid[1]) {
                    video = new ARVideo;
                    video->openTransparentVideoFile("transparentvideo.mp4", texid[1]);
                    video_renderer = renderer[1];
                    /****************/
                    shouldShowStar = false;
                    /****************/
                }
                else if(frame.targets()[0].target().name() == std::string("idback") && texid[2]) {
                    /****************/
                    shouldShowStar = true;
                    /****************/
                }
                /****************/
                else if(frame.targets()[0].target().name() == std::string("z1")||frame.targets()[0].target().name() == std::string("z2") || frame.targets()[0].target().name() == std::string("z3") || frame.targets()[0].target().name() == std::string("z4")) {
                    shouldShowStar = true;
                }
                else if((frame.targets()[0].target().name() == std::string("y1") || frame.targets()[0].target().name() == std::string("y2")) && texid[2]) {
                    video = new ARVideo;
                    video->openStreamingVideo("http://www.w3school.com.cn/example/html5/mov_bbb.mp4", texid[2]);
                    video_renderer = renderer[2];
                    shouldShowStar = false;
                }
                /****************/
            }
            if (video) {
                video->onFound();
                tracked_target = id;
                active_target = id;
            }
        }
        Matrix44F projectionMatrix = getProjectionGL(camera_.cameraCalibration(), 0.2f, 500.f);
        Matrix44F cameraview = getPoseGL(frame.targets()[0].pose());
        
        /***********/
        cameraview4Matrix = cameraview;
        projection4Matrix = projectionMatrix;
        /***********/
       
        
        ImageTarget target = frame.targets()[0].target().cast_dynamic<ImageTarget>();
        if(tracked_target) {
            video->update();
            video_renderer->render(projectionMatrix, cameraview, target.size());
        }
    } else {
        if (tracked_target) {
            video->onLost();
            tracked_target = 0;
        }
        /****************/
        isTracked = false;
        /****************/
    }
}

bool HelloARVideo::clear()
{
    AR::clear();
    if(video){
        delete video;
        video = NULL;
        tracked_target = 0;
        active_target = 0;
    }
    return true;
}

}
}
EasyAR::samples::HelloARVideo ar;

/////////////////////


@interface OpenGLView ()
{
}

@property(nonatomic, strong) CADisplayLink * displayLink;

- (void)displayLinkCallback:(CADisplayLink*)displayLink;

@end

@implementation OpenGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = frame.size.height = MAX(frame.size.width, frame.size.height);
    self = [super initWithFrame:frame];
    if(self){
        [self setupGL];

        EasyAR::initialize([key UTF8String]);
        ar.initGL();
    }

    return self;
}

- (void)dealloc
{
    ar.clear();
}

- (void)setupGL
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;

    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context)
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
    if (![EAGLContext setCurrentContext:_context])
        NSLog(@"Failed to set current OpenGL context");

    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);

    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);

    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);

    GLuint depthRenderBuffer;
    glGenRenderbuffers(1, &depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
}

/***********/ //矩阵转换的"胶水代码"
- (void)getMatrix {
    
    SCNMatrix4 m = SCNMatrix4Identity;
    m.m11 = ar.cameraview4Matrix.data[0];
    m.m12 = ar.cameraview4Matrix.data[1];
    m.m13 = ar.cameraview4Matrix.data[2];
    m.m14 = ar.cameraview4Matrix.data[3];
    
    m.m21 = ar.cameraview4Matrix.data[4];
    m.m22 = ar.cameraview4Matrix.data[5];
    m.m23 = ar.cameraview4Matrix.data[6];
    m.m24 = ar.cameraview4Matrix.data[7];
    
    m.m31 = ar.cameraview4Matrix.data[8];
    m.m32 = ar.cameraview4Matrix.data[9];
    m.m33 = ar.cameraview4Matrix.data[10];
    m.m34 = ar.cameraview4Matrix.data[11];
    
    m.m41 = -ar.cameraview4Matrix.data[12];
    m.m42 = -ar.cameraview4Matrix.data[13];
    m.m43 = ar.cameraview4Matrix.data[14];
    m.m44 = ar.cameraview4Matrix.data[15];
    self.cameraview4Matrix = m;
    
    SCNMatrix4 n = SCNMatrix4Identity;
    n.m11 = ar.projection4Matrix.data[0];
    n.m12 = ar.projection4Matrix.data[1];
    n.m13 = ar.projection4Matrix.data[2];
    n.m14 = ar.projection4Matrix.data[3];
    
    n.m21 = ar.projection4Matrix.data[4];
    n.m22 = ar.projection4Matrix.data[5];
    n.m23 = ar.projection4Matrix.data[6];
    n.m24 = ar.projection4Matrix.data[7];
    
    n.m31 = ar.projection4Matrix.data[8];
    n.m32 = ar.projection4Matrix.data[9];
    n.m33 = ar.projection4Matrix.data[10];
    n.m34 = ar.projection4Matrix.data[11];
    
    n.m41 = ar.projection4Matrix.data[12];
    n.m42 = ar.projection4Matrix.data[13];
    n.m43 = ar.projection4Matrix.data[14];
    n.m44 = ar.projection4Matrix.data[15];
    self.projection4Matrix = n;
    
    
}
/***********/

- (void)start{
    ar.initCamera();
    ar.loadAllFromJsonFile("targets.json");
    ar.loadFromImage("namecard.jpg");
    ar.start();

    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stop
{
    ar.clear();
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    if (!((AppDelegate*)[[UIApplication sharedApplication]delegate]).active)
        return;
    ar.render();
    
    /***********/
    [self getMatrix];
    self.isTracked = ar.isTracked;
    self.shouldShowStar = ar.shouldShowStar;
    /***********/
    
    (void)displayLink;
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    BOOL isPortrait = FALSE;
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            isPortrait = TRUE;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            isPortrait = FALSE;
            break;
        default:
            break;
    }
    ar.setPortrait(isPortrait);
    ar.resizeGL(frame.size.width, frame.size.height);
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            EasyAR::setRotationIOS(270);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            EasyAR::setRotationIOS(90);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            EasyAR::setRotationIOS(180);
            break;
        case UIInterfaceOrientationLandscapeRight:
            EasyAR::setRotationIOS(0);
            break;
        default:
            break;
    }
}

@end
