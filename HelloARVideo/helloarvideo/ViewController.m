/**
* Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
* EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
* and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
*/

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet SCNView *scnView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.glView = [[OpenGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
    [self.glView setOrientation:self.interfaceOrientation];
    
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(printMatrix) userInfo:nil repeats:YES];
    
}
- (void)printMatrix {
    SCNMatrix4 p = self.glView.projection4Matrix;
    SCNMatrix4 c = self.glView.cameraview4Matrix;
    
    //NSLog(@"projection4Matrix--%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf",p.m11,p.m12,p.m13,p.m14,p.m21,p.m22,p.m23,p.m24);
    NSLog(@"projection4Matrix--%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf",c.m11,c.m12,c.m13,c.m14,c.m21,c.m22,c.m23,c.m24);
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.glView start];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.glView stop];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self.glView resize:self.view.bounds orientation:self.interfaceOrientation];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [self.glView setOrientation:toInterfaceOrientation];
}

@end
