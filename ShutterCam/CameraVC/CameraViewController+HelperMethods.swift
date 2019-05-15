//
//  CameraViewController+HelperMethods.swift
//  Camera
//
//  Created by Isaac Raval on 5/14/19.
//  Copyright © 2019 Isaac Raval. All rights reserved.
//

import UIKit
import AVKit
import CoreImage

extension CameraViewController {
    //Setup the view
    func setupView () {
        
        //Set default button alpha to indicate it is off
        buttonOutlet.alpha = 0.3
        
        captureButton.layer.cornerRadius = captureButton.frame.size.width / 2
        captureButton.clipsToBounds = true
        
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            fatalError("No video device found")
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous deivce object
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object
            captureSession = AVCaptureSession()
            
            // Set the input devcie on the capture session
            captureSession?.addInput(input)
            
            // Get an instance of ACCapturePhotoOutput class
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            
            // Set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput!)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the input device
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            //Initialise the video preview layer and add it as a sublayer to the viewPreview view's layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
            
            //start video capture
            captureSession?.startRunning()
            
        } catch {
            //If any error occurs, simply print it out
            print(error)
            return
        }
    }
    
    //Take the picture
    func takePicture() {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        //Indicate photo was taken
        UIView.animate(withDuration: 0.4) {
            self.captureButton.layer.opacity = 0.2
        }
        UIView.animate(withDuration: 0.4) {
            self.captureButton.layer.opacity = 1
        }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)

    }
    
    //Setup image preview layer
    func setupPreviewLayer() {
        videoPreviewLayer?.frame = view.bounds
        if let previewLayer = videoPreviewLayer ,(previewLayer.connection?.isVideoOrientationSupported ?? true) {
            previewLayer.connection?.videoOrientation = UIApplication.shared.statusBarOrientation.videoOrientation ?? .portrait
        }
        
    }
    
    //Receive the results of photo capture as a JPEG.
    func retrieveResultsOfPhotoCaptureAsJPG (didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        
        // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        
        // Initialise an UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)

        //Add effect and then save image, or just save image
        if(EFFECT_SEPIA_ENABLED) {
            // Get CIImage
            let inputCIImage = CIImage.init(data: imageData)
            
            //Set filter
            let context = CIContext(options: nil)
            let filter = CIFilter(name: "CICrystallize")!
            filter.setValue(inputCIImage, forKey: kCIInputImageKey)
            filter.setValue(30, forKey: kCIInputRadiusKey)
            filter.setValue(inputCIImage, forKey: kCIInputImageKey)
            
            // Get the filtered output image and return it (all the conversions are to circumvent a bug where the image will not save)
            let outputImageCIimage = filter.outputImage! //Get as CIimage
            guard let cgImage = context.createCGImage(outputImageCIimage, from: outputImageCIimage.extent) else { return } //Conv to CGImage

            let newImage = UIImage(cgImage: cgImage) //Conv to UIimage
            
            // Save captured image with added effect to Photos
            UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil)
        }
        else {
            if let image = capturedImage {
                // Save captured image to Photos
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
}

extension CameraViewController {
    //Toggle Crystallize mode/button on and off
    @IBAction func toggleCrystallizeEffect(_ sender: UIButton) {
        //Toggle on/off
        EFFECT_SEPIA_ENABLED = !EFFECT_SEPIA_ENABLED
        //Indicate if mode is on or off
        if(!EFFECT_SEPIA_ENABLED) { buttonOutlet.alpha = 0.3}
        else {buttonOutlet.alpha = 1}
    }
}

//Video orientation options
extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}
