//
//  CameraViewController.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-10-05.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var snapButton: UIButton!
    
    var image: UIImage?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var frontCam: AVCaptureDevice?
    var backCam :AVCaptureDevice?
    var currentCam: AVCaptureDevice?
    
    var photoOutput: AVCapturePhotoOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSnapbuttonSettings()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreview()
        startCaptureSession()
    }
    
    func startCaptureSession(){
        captureSession?.startRunning()
    }
    
    func setupPreview(){
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        videoPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(videoPreviewLayer!, at: 0)
        
    }
    
    func setupInputOutput(){
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCam!)
            captureSession?.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession?.addOutput(photoOutput!)
            
        } catch {
            print(error)
        }
    }
    
    func setupCaptureSession(){
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    func setupDevice(){
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCam = device
            }else if device.position == AVCaptureDevice.Position.front{
                frontCam = device
            }
        }
        currentCam = backCam
    }
    
    @IBAction func takePicture(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    func setSnapbuttonSettings() {
        snapButton.layer.cornerRadius = snapButton.frame.width / 2
        snapButton.backgroundColor = UIColor.white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewPhoto" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = self.image
        }
    }
    @IBAction func cancelCamera(_ sender: Any) {
        self.performSegue(withIdentifier: "closeCamera", sender: self)
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let tmpImage = UIImage(data: imageData)
            let tmpData = UIImageJPEGRepresentation(tmpImage!, 0.05)
            image = UIImage(data: tmpData!)
            performSegue(withIdentifier: "previewPhoto", sender: nil)
        }
    }
}
