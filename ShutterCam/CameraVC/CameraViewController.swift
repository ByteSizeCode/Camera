//
//  CameraViewController.swift
//  Camera
//
//  Created by Isaac Raval on 5/14/19.
//  Copyright © 2019 Isaac Raval. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    //Camera IBOutlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    //Camera properties
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    
    //More IBOutlets
    @IBOutlet weak var buttonOutlet: UIButton!
    
    //More properties
    var EFFECT_SEPIA_ENABLED = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    //Called when the bounds change for a VC's view
    override func viewDidLayoutSubviews() {
        setupPreviewLayer()
    }
    
    @IBAction func didTapShutterButton(_ sender: Any) {
        takePicture()
    }
}

extension CameraViewController : AVCapturePhotoCaptureDelegate {
    //Receive the results of photo capture as a JPEG
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        //Receive the results of photo capture as a JPEG
        retrieveResultsOfPhotoCaptureAsJPG(
                didFinishProcessingPhoto: photoSampleBuffer, previewPhoto:previewPhotoSampleBuffer, resolvedSettings: resolvedSettings, bracketSettings: bracketSettings, error: error)
    }
}
