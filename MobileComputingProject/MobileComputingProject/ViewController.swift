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
    
    // Singleton Model
    var canaryModel: CanaryModel = CanaryModel.sharedInstance

    // Trashcan
    var trashCanView:UIImageView = UIImageView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///////////////////////
        // ***************** //
        // *** LOAD DATA *** //
        // ***************** //
        ///////////////////////
        
        // 1. Load floor plan
        let floorImageURL = canaryModel.getClosestLibrary().getFloor().urlToFloorPlan
        
        // 2. Load messages
        for message in canaryModel.getClosestLibrary().getFloor().messages {
            addPoi(x: CGFloat(message.x), y: CGFloat(message.y))
        }
        
        // Scroll level specification
        self.floorPlanScrollView.minimumZoomScale = 0.0
        self.floorPlanScrollView.maximumZoomScale = 10.0
        
        // Setup gesture recognition
        let addPinRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addMessage))
        floorPlanView.isUserInteractionEnabled = true
        floorPlanView.addGestureRecognizer(addPinRecognizer)
        
        do {
            let url = URL(string:floorImageURL)
            let data = try Data.init(contentsOf: url!)
            self.floorPlanView.image = UIImage(data: data)
        }catch{
            print(error)
        }
        print("started")
        
        setupTrashcan()
    }
    
    /*
        Saves the location of the point
    */
    @objc func addMessage(gesture: UITapGestureRecognizer){
        if gesture.state == .began {
            // Save coordinates for model to fetch
            let point = gesture.location(in: gesture.view)
            canaryModel.longPressXCoord = Double(point.x)
            canaryModel.longPressXCoord = Double(point.y)
            
            //Create menu for type of message to add
            createPopOver()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.floorPlanView
    }
    
    func addPoi(x: CGFloat, y: CGFloat){
        do {
            let url = URL(string:"https://cdn.pixabay.com/photo/2014/06/17/08/45/bubble-370270_960_720.png")
            let data = try Data.init(contentsOf: url!)
            let image = UIImage(data: data)
            let view = UIImageView(frame: CGRect(x: x, y: y, width: 48, height: 48))
            view.image = image
            
            // Add a gesture recognizer to every created pin to move it
            let movePinRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(poiTapped))
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(movePinRecognizer)

            self.floorPlanView.addSubview(view)
            UIImpactFeedbackGenerator.init(style: UIImpactFeedbackStyle.heavy).impactOccurred()
        } catch {
            print(error)
        }
    }

    // Moving pins
    // Offset is stored when gesture began, but same for every change of the gesture
    var movePoiOffsetX:CGFloat = 0
    var movePoiOffsetY:CGFloat = 0
    @objc func poiTapped(gesture: UILongPressGestureRecognizer) {
        // On LongPress begin
        // Give haptic feedback (vibration)
        // Save offset
        // Show trash icon
        if gesture.state == .began {
            UIImpactFeedbackGenerator.init(style: UIImpactFeedbackStyle.heavy).impactOccurred()
            movePoiOffsetX = gesture.location(in: gesture.view).x
            movePoiOffsetY = gesture.location(in: gesture.view).y
            trashCanView.isHidden = false
        }
        // On LongPress change
        // Get LongPress position
        // Calculate new position for po (tap - offset)
        // set poi to new position
        else if gesture.state == .changed {
            let view = gesture.view
            
            let floorPlanX = gesture.location(in: floorPlanView).x
            let floorPlanY = gesture.location(in: floorPlanView).y
            let newX = floorPlanX - movePoiOffsetX
            let newY = floorPlanY - movePoiOffsetY
            
            view!.frame = CGRect(x: newX, y: newY, width: 48, height: 48)
        }
        // If LongPress ended
        // And Poi dragged to trash
        // Delete Poi, hide trash
        else if gesture.state == .ended {
            if (trashCanView.frame.intersects(view.convert(gesture.view!.frame, from: floorPlanView))) {
                // FIXME: Check if user has right to delete Poi
                gesture.view!.removeFromSuperview()
                // FIXME: Send delete request to firebase when deleting Poi
            }
            trashCanView.isHidden = true
        }
    }
    
    
    
    func createPopOver(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Text", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Paint", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.segueToPaintTool()}))
        alert.addAction(UIAlertAction(title: "Photo", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true)
    }
    
    func segueToPaintTool(){
        self.performSegue(withIdentifier: "paintSegue", sender: self)
    }
    
    func setupTrashcan(){
        // Load trashcan icon
        do {
            let url = URL(string:"https://i.imgur.com/jhav5sW.png")
            let data = try Data.init(contentsOf: url!)
            let image = UIImage(data: data)
            let viewX = UIScreen.main.bounds.width / 2 - 64 / 2
            let viewY = UIScreen.main.bounds.height - 96
            trashCanView = UIImageView(frame: CGRect(x: viewX, y: viewY, width: 64, height: 64))
            trashCanView.image = image
            view.addSubview(trashCanView)
            trashCanView.isHidden = true
            trashCanView.isUserInteractionEnabled = false
        } catch {
            print(error)
        }
    }

}

