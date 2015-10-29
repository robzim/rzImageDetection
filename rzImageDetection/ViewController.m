//
//  ViewController.m
//  rzImageDetection
//
//  Created by Robert Zimmelman on 10/24/15.
//  Copyright © 2015 Robert Zimmelman. All rights reserved.
//

#import "ViewController.h"
#import "CoreImage/CoreImage.h"
#import "ImageIO/ImageIO.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *myImageView;
@end

@implementation ViewController

@synthesize myImageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    NSString *myPath = [[NSBundle mainBundle] pathForResource:@"DSC00465-001" ofType:@"JPG"];
//    NSString *myPath = [[NSBundle mainBundle] pathForResource:@"Andy and Danny" ofType:@"JPG"];
//    NSString *myPath = [[NSBundle mainBundle] pathForResource:@"DSC01726" ofType:@"JPG"];
    NSString *myPath = [[NSBundle mainBundle] pathForResource:@"10 faces" ofType:@"jpg"];
//    NSString *myPath = [[NSBundle mainBundle] pathForResource:@"10 more faces" ofType:@"jpg"];
    NSURL *myTempURL = [NSURL fileURLWithPath:myPath];
    CIImage *myTempImage = [CIImage imageWithContentsOfURL:myTempURL];
    
    CIFilter *myNoir = [CIFilter filterWithName:@"CIPhotoEffectNoir"];
    
    CIFilter *mySepiaTone = [CIFilter filterWithName:@"CISepiaTone"];
//    CIContext *mySepiaToneContext = [CIContext contextWithOptions:nil];
    CIContext *myNoirContext = [CIContext contextWithOptions:nil];
    [myNoir setValue:myTempImage forKey:kCIInputImageKey];
    [mySepiaTone setValue:myTempImage forKey:kCIInputImageKey];
    
//    CIImage *myResult = [mySepiaTone valueForKey:kCIOutputImageKey];
    CIImage *myResult = [myNoir valueForKey:kCIOutputImageKey];
    
//    CGImageRef ref = [mySepiaToneContext createCGImage:myResult fromRect:myResult.extent];
    CGImageRef ref = [myNoirContext createCGImage:myResult fromRect:myResult.extent];
    
    
    UIImage *myRefImage = [[UIImage alloc] initWithCGImage:ref];
    [myImageView setImage:myRefImage];

    CIContext *myFaceDetectorContext = [CIContext contextWithOptions:nil];                    // 1
//    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh, CIDetectorMinFeatureSize: @0.01 };      // 2
    NSDictionary *myFaceDetectorOptions = [NSDictionary dictionaryWithObjectsAndKeys:@"CIDetectorAccuracy", @"CIDetectorAccuracyHigh", @"CIDetectorMinFeatureSize", @"0.01",  nil];
    CIDetector *myFaceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:myFaceDetectorContext
                                              options:myFaceDetectorOptions];                    // 3
//    opts = @{ CIDetectorImageOrientation :
//                  [[myTempImage properties] valueForKey:kCGImagePropertyOrientation] }; // 4
    
    
    
    NSArray *myFaceFeatures = [myFaceDetector featuresInImage:myTempImage options:myFaceDetectorOptions];        // 5
    for (CIFaceFeature *f in myFaceFeatures)
    {
        
//        NSLog(@"f = %@",f);
        NSLog(@"bounds = %@",NSStringFromCGRect(f.bounds));
        if (f.hasLeftEyePosition){
            NSLog(@"Left eye %g %g", f.leftEyePosition.x, f.leftEyePosition.y);
            
            CIImage *myLEMarker = [CIImage imageWithColor:[CIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.1f]];
            
//            CIFilterShape *myFilterShape = [[CIFilterShape alloc] initWithRect:CGRectMake(f.leftEyePosition.x, f.leftEyePosition.y, 10.0f, 10.0f)];
            
            CIFilter *myFilter = [CIFilter filterWithName:@"CIOverlayBlendMode"];
            [myFilter setValue:myLEMarker forKey: kCIInputImageKey ];
//            [myFilter setValue:myFilterShape forKey: kCIInputMaskImageKey ];
            [myFilter setValue:myImageView.image.CIImage forKey: kCIInputBackgroundImageKey ];
            
//            [myImageView setImage:[UIImage imageWithCIImage: [myFilter valueForKey:kCIOutputImageKey]]];
            
//            [[myFilter inputKeys ]
            
            CIImage *MyProcesedImage = [[CIImage alloc] init];
            MyProcesedImage = nil;
        }
        if (f.leftEyeClosed)
        {
            NSLog(@"Left Eye is Closed");
        }

        if (f.hasRightEyePosition){
            NSLog(@"Right eye %g %g", f.rightEyePosition.x, f.rightEyePosition.y);
            UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(f.rightEyePosition.x, f.rightEyePosition.y, 10, 10)];
            [myLabel setText:@"RE"];
            [myImageView addSubview:myLabel];
        }
        if (f.rightEyeClosed)
        {
            NSLog(@"Right Eye is Closed");
        }

        if (f.hasMouthPosition)
        {
            NSLog(@"Mouth %g %g", f.mouthPosition.x, f.mouthPosition.y);
        }
        if (f.hasSmile)
        {
            NSLog(@"SMILING");
        }
        if (f.hasFaceAngle)
        {
            NSLog(@"Has a Face Angle");
            NSLog(@"Face Angle is: %f",f.faceAngle);
        }

    }
    
    
    // end of face detector part
    
    
    // begin rectangle detector part
    CIDetector *myRectangleDetector = [CIDetector detectorOfType:CIDetectorTypeRectangle
                                                         context:myFaceDetectorContext
                                                         options:myFaceDetectorOptions];
    
    NSArray *myRectangleFeatures = [myRectangleDetector featuresInImage:myTempImage options:myFaceDetectorOptions];
    NSLog(@" %u Rectangles Detected",myRectangleFeatures.count);
    if (myRectangleFeatures.count == 0) {
        NSLog(@"No Rectangles Detected!");
    }
    for (CIRectangleFeature *rf in myRectangleFeatures)
    {
            NSLog(@"Top Location = %f %f %f %f",rf.topLeft.x, rf.topLeft.y, rf.topRight.x, rf.topRight.y);
            NSLog(@"Bottom Location = %f %f %f %f",rf.bottomLeft.x, rf.bottomLeft.y, rf.bottomRight.x, rf.bottomRight.y);
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)myDetectFaces:(id)sender {
}

- (IBAction)myQuit:(id)sender {
    exit(0);
}

@end
