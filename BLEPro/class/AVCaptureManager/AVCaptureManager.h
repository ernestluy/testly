//
//  AVCaptureManager.h
//  SlowMotionVideoRecorder
//
//  Created by shuichi on 12/17/13.
//  Copyright (c) 2013 Shuichi Tsutsumi. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol AVCaptureManagerDelegate <NSObject>
- (void)didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
                                      error:(NSError *)error;
-(void)captureImageEnd:(UIImage*)timg;
@end


@interface AVCaptureManager : NSObject

@property (nonatomic, assign) id<AVCaptureManagerDelegate> delegate;
@property (nonatomic, readonly) BOOL isRecording;

- (id)initWithPreviewView:(UIView *)previewView;
- (void)changePreviewOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)toggleContentsGravity;
- (void)resetFormat;
- (void)switchFormatWithDesiredFPS:(CGFloat)desiredFPS;
- (void)startRecording;
- (void)stopRecording;

-(void)Captureimage;
@end
