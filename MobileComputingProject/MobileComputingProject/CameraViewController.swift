//
//  CameraViewController.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-10-05.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var snapButton: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            previewView.layer.addSublayer(videoPreviewLayer!)
        } catch {
            print(error)
        }
        
        setSnapbuttonSettings()
        previewView.addSubview(closeBtn)
        previewView.bringSubview(toFront: closeBtn)
        
        captureSession?.startRunning()
        
        
    }
    @IBAction func takePicture(_ sender: Any) {
        //TODO: segueway to paint view!
        print("SNAP NAP CRAP!!")
    }
    
    func setSnapbuttonSettings() {
        snapButton.backgroundColor = .clear
        snapButton.layer.cornerRadius = snapButton.frame.height/2
        snapButton.layer.borderWidth = 5.0
        snapButton.layer.borderColor = UIColor.white.cgColor
        
        previewView.addSubview(snapButton)
        previewView.bringSubview(toFront: snapButton)
    }
    @IBAction func closeCamera(_ sender: Any) {
        print("Close close close...")
        self.doSegueBack()
    }
    
    @objc func doSegueBack(){
        self.performSegue(withIdentifier: "closeCamera", sender: self)
    }
    
}
