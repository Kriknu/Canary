//
//  ViewController.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-09-13.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var floorPlanView: UIImageView!
    @IBOutlet weak var floorPlanScrollView: UIScrollView!
    
    // GPS
    var locationManager: CLLocationManager = CLLocationManager()
    var longitude: Double {
        get{
            return Double(self.getLocation()?.coordinate.longitude ?? 0);
        }
    }
    var latitude: Double {
        get{
            return Double(self.getLocation()?.coordinate.latitude ?? 0);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Scroll level specification
        self.floorPlanScrollView.minimumZoomScale = 1.0
        self.floorPlanScrollView.maximumZoomScale = 6.0
        
        // Setup gesture recognition
        let addPinRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(imageTapped))
        floorPlanView.isUserInteractionEnabled = true
        floorPlanView.addGestureRecognizer(addPinRecognizer)
        
        // Setup location manager for retrieving GPS position
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }else{
            print("Location services not enabled")
        }
        
        do {
            let url = URL(string:"https://i.imgur.com/DkvC9R6.png")
            let data = try Data.init(contentsOf: url!)
            self.floorPlanView.image = UIImage(data: data)
        }catch{
            print(error)
        }
        print("started")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.floorPlanView
    }
    
    @objc func imageTapped(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: gesture.view)
        print("X: ")
        print(point.x)
        print("Y: ")
        print(point.y)
        print("latitude: \(latitude) || longitude: \(longitude)")
        //addPoi(x: point.x, y: point.y)
        createPopOver()
    }
    
    func addPoi(x: CGFloat, y: CGFloat){
        do {
            let url = URL(string:"https://cdn.pixabay.com/photo/2014/06/17/08/45/bubble-370270_960_720.png")
            let data = try Data.init(contentsOf: url!)
            let image = UIImage(data: data)
            let view = UIImageView(frame: CGRect(x: x, y: y, width: 48, height: 48))
            view.image = image
            self.floorPlanView.addSubview(view)
            UIImpactFeedbackGenerator.init(style: UIImpactFeedbackStyle.heavy).impactOccurred()
        } catch {
            print(error)
        }
    }
    
    func getLocation() -> CLLocation? {
        return self.locationManager.location
    }
    
    func createPopOver(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Text", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Paint", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Photo", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.test()}))
        present(alert, animated: true)
    }
    
    func test(){
        self.performSeg
    }

}

