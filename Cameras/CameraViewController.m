//
//  CameraViewController.m
//  Cameras
//
//  Created by tamqn on 4/22/16.
//  Copyright © 2016 tamqn. All rights reserved.
//

#import "CameraViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ShowImageViewController.h"

@interface CameraViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) MPMoviePlayerController *videoController;
@property (readwrite, nonatomic) BOOL isVideo;
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.videoController];
    self.array = [NSMutableArray new];
}

- (IBAction)captureVideo:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.isVideo = YES;
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
}

- (IBAction)takePhoto:(UIButton *)sender {
    self.isVideo = NO;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (self.isVideo) {
        self.videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:NULL];
        NSArray *xxx = [self extractFirstFrameFromFilepath:self.videoURL];
        [self performSegueWithIdentifier:@"ShowImageViewController" sender:xxx];
    }else{
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"ShowImageViewController"]) {
        // Get reference to the destination view controller
        ShowImageViewController *bookVC = [segue destinationViewController];
        NSArray *arrayxx = (NSArray*)sender;
        bookVC.array = arrayxx;
    }
}

- (NSArray*)extractFirstFrameFromFilepath:(NSURL*)filepath
{
    NSMutableArray *array = [NSMutableArray new];
    AVURLAsset *movieAsset = [[AVURLAsset alloc] initWithURL:filepath options:nil];
    
    NSTimeInterval durationInSeconds = 0.0;
    if (movieAsset)
        durationInSeconds = CMTimeGetSeconds(movieAsset.duration);
    
    AVAssetImageGenerator *assetImageGemerator = [[AVAssetImageGenerator alloc] initWithAsset:movieAsset];
    assetImageGemerator.appliesPreferredTrackTransform = YES;
    for (NSInteger index=0; index<durationInSeconds*24; index++) {
        CGImageRef frameRef = [assetImageGemerator copyCGImageAtTime:CMTimeMake(index, 24) actualTime:nil error:nil];
        UIImage *image = [[UIImage alloc] initWithCGImage:frameRef];
        [array addObject:image];
    }
    return [array copy];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)videoPlayBackDidFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    // Stop the video player and remove it from view
    [self.videoController stop];
    [self.videoController.view removeFromSuperview];
    self.videoController = nil;
    // Display a message
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Video Playback" message:@"Just finished the video playback. The video is now removed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
