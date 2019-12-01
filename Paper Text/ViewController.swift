//
//  ViewController.swift
//  Paper Text
//
//  Created by Roy Bailey II on 11/30/19.
//  Copyright © 2019 Roy Bailey II. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var session = AVCaptureSession()
    var request = [VNRequest]()

    override func viewDidLoad() {
        super.viewDidLoad()
        startLiveVideo()
        startTextDetection()
        // Do any additional setup after loading the view.
    }
    
    func startLiveVideo() {
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos:DispatchQoS.QoSClass.default))
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        
        session.startRunning()
    }

    override func viewDidLayoutSubviews() {
        imageView.layer.sublayers?[0].frame = imageView.bounds
        
    }
    func startTextDetection() {
        let textRequest = VNDetectTextRectanglesRequest(completionHandler: self.detectTextHandler)
        textRequest.reportCharacterBoxes = true
        self.request = [textRequest]
    }
    func detectTextHandler(request: VNRequest, error: Error?){
        guard let observations = request.results else {
            print("no result")
            return
        }
        let results = observations.map({$0 as? VNTextObservation})
        
        DispatchQueue.main.async {
            self.imageView.layer.sublayers?.removeSubrange(1...)
            for region in result {
                guard let region = region else {
                    continue
                }
                
                self.highlightWord(box: region)
                
                if let boxes = region.characterBoxes {
                    for characterBox in boxes {
                        self.highlightLetters(box: characterBox)
                }
                    
                    func highlightWord(box: VNTextObservation){
                        guard let boxes = box.characterBoxes else {
                            return
                        }
                        
                        var maxX: CGFloat = 9999.0
                        var minX: CGFloat = 0.0
                        var maxY: CGFloat = 9999.0
                        var minY: CGFloat = 0.0
                        
                        for char in boxes {
                            if char.bottomLeft.x < maxX {
                                maxX = char.bottomLeft.x
                            }
                            if char.bottomRight.x > minX {
                                minX = char.bottomRight.x
                            }
                            if char.bottomRight.y < maxY {
                                maxy = char.bottomRight.y
                            }
                            if char.topRight.y > minY {
                                minY = char.topRight.y
                            }
                        }
                    
                        let xCord = maxX * imageView.frame.size.width
                        let yCord = (1 - minY) * imageView.frame.size.height
                        let width = (minX - maxX) * imageView.frame.size.width
                        let height = (minY - maxY) * imageView.frame.size.height
                        
                        let outline = CALayer()
                        outline.frame = CGRect(x: xCord, y: yCord, width: width, height: height)
                        outline.borderWidth = 2.0
                        outline.borderColor = UIColor.red.cgColor
                        
                        imageView.layer.addSublayer(outline)
                        
                    }
                    
                    session ViewController: AVCaptureVideoDataOutputSampleBufferDelegate
                    
            }
        }
        
    }
}

}
