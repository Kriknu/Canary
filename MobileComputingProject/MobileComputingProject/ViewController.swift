//
//  ViewController.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-09-13.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseUI
import Firebase

class ViewController: UIViewController, UIScrollViewDelegate, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var floorPlanView: UIImageView!
    @IBOutlet weak var floorPlanScrollView: UIScrollView!
    
    // Singleton Model
    var canaryModel: CanaryModel = CanaryModel.sharedInstance

    // Trashcan
    var trashCanView:UIImageView = UIImageView()
    
    // Minimap
    @IBOutlet weak var minimapView: UIView!
    var minimapCurrentView: UIImageView!
    
    
    
    var zoomLevelTreshhold: CGFloat = 1.5
    var lastZoomLevel: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Load floor plan
        let floorImageURL = canaryModel.getClosestLibrary().getFloor().urlToFloorPlan

        // 2. Setup Message Observer
        self.setupFirebaseMessageObserver()
        
        // 3. Setup Minimap
        view.bringSubview(toFront: minimapView)
        var tmpMinimapImage = UIImage()
        do {
            let tmpUrl = URL(string:"https://firebasestorage.googleapis.com/v0/b/canary-e717d.appspot.com/o/floorplans%2FFloorplan_v4.png?alt=media&token=4f9736ce-288d-41e9-bf17-eb1c2268e50b")
            let tmpData = try Data.init(contentsOf: tmpUrl!)
            tmpMinimapImage = UIImage(data: tmpData)!
        }catch{
            print("Error getting Minimap image")
        }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: minimapView.frame.width, height: minimapView.frame.width))
        imageView.image = tmpMinimapImage
        imageView.alpha = 0.5
        minimapView.contentMode = .scaleToFill
        minimapView.backgroundColor = .clear
        minimapView.layer.borderWidth = 0.5
        minimapView.layer.borderColor = UIColor.lightGray.cgColor
        
        // Minimap marker
        print(self.view.frame.width)
        print(self.view.frame.height)
        let tmpWidth = self.view.frame.width / (11*floorPlanScrollView.zoomScale)
        let tmpHeight = self.view.frame.height / (11*floorPlanScrollView.zoomScale)
        minimapCurrentView = UIImageView(frame: CGRect(x: 0, y: 0, width: tmpWidth, height: tmpHeight))
        minimapCurrentView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        
        minimapView.addSubview(imageView)
        minimapView.addSubview(minimapCurrentView)
        minimapView.isUserInteractionEnabled = false
        
        // Scroll Zoom-level specification
        self.floorPlanScrollView.minimumZoomScale = 0.4
        self.floorPlanScrollView.maximumZoomScale = 2.0
        
        // Setup gesture recognition
        let addPinRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addMessage))
        self.floorPlanView.isUserInteractionEnabled = true
        self.floorPlanView.addGestureRecognizer(addPinRecognizer)
        self.floorPlanView.sd_setImage(with: canaryModel.downloadImageReferenceFromFirebase("floorplans/Floorplan_v4.png"))
        
        self.setupTrashcan()
    }


    /*
        Saves the location of the point
    */
    @objc func addMessage(gesture: UITapGestureRecognizer){
        if gesture.state == .began {
            // Save coordinates for model to fetch
            let point = gesture.location(in: gesture.view)
            self.canaryModel.latestLongPressXCoord = Float(point.x)
            self.canaryModel.latestLongPressYCoord = Float(point.y)
            let strTag = "\(String(UUID().hashValue))\(String(canaryModel.messageId))"
            let tmpTag = Int(strTag)
            self.canaryModel.latestID = tmpTag ?? -1
            
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

    func addPois(){
        let msgs = self.canaryModel.getClosestLibrary().getFloor().messages
        for message in msgs {
            let x = CGFloat(message.x)
            let y = CGFloat(message.y)
            let bubbleWidth:CGFloat = 72
            let bubbleHeight:CGFloat = 84
            let iconWidth:CGFloat = 48
            let iconHeight:CGFloat = 48
            let bubble = UIImageView(frame: CGRect(x: x, y: y, width: bubbleWidth, height: bubbleHeight))
            bubble.image = UIImage(named: "Bubble")
            let image: UIImage = getPoiImageUrl(message.type.rawValue)
            let view = UIImageView(frame: CGRect(x: (bubbleWidth-iconWidth)/2, y: (bubbleWidth-iconHeight)/2, width: iconWidth, height: iconHeight))
            view.image = image
            bubble.tag = message.id
            // Add a gesture recognizer to every created pin to move it
            let movePinRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.poiTapped))
            bubble.isUserInteractionEnabled = true
            bubble.addGestureRecognizer(movePinRecognizer)
            bubble.addSubview(view)
            self.floorPlanView.addSubview(bubble)
            UIImpactFeedbackGenerator.init(style: UIImpactFeedbackStyle.heavy).impactOccurred()
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
            
            let tmpMessage = canaryModel.getMessage(view!.tag)
            tmpMessage?.x = Float(newX)
            tmpMessage?.y = Float(newY)
            let tmpPoint = CGPoint(x: newX, y: newY)
            view!.frame.origin = tmpPoint
            if trashCanView.frame.intersects(self.view.convert(view!.frame, from: floorPlanView)) {
                print("INTERSECTION FOUND")
                // TODO: Fix visuals so that the user knows they are about to delete a poi
            }
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
            canaryModel.deleteMessage(gesture.view!.tag)
            trashCanView.isHidden = true
        }
    }
    
    func addDropShadowToPOI(view: UIView) {
        //Add drop shadow to POI
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 1.0
        view.clipsToBounds = false
    }
    
    func createPopOver(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Text", style: UIAlertActionStyle.default, handler:
            {(alert: UIAlertAction!) in self.segueToTextTool()}))
        alert.addAction(UIAlertAction(title: "Paint", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.segueToPaintTool()}))
        alert.addAction(UIAlertAction(title: "Photo", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.segueToCameraTool()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in self.alertControllerBackgroundTapped()}))
        present(alert, animated: true)
    }
    
    @objc func alertControllerBackgroundTapped() {
        //TODO: Add functionality to dismiss temp-POI
        print("TAP TAP TAP !!! CLICK CLICK CLICK!!!")
    }
    
    func segueToPaintTool(){
        self.performSegue(withIdentifier: "paintSegue", sender: self)
    }
    
    func segueToCameraTool(){
        self.performSegue(withIdentifier: "cameraSegue", sender: self)
    }
    
    func segueToTextTool(){
        self.performSegue(withIdentifier: "textSegue", sender: self)
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
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //print("Zoomlevel: \(floorPlanScrollView.zoomScale)")
        minimapCurrentView.frame.size = CGSize(width: self.view.frame.width / (10*floorPlanScrollView.zoomScale), height: self.view.frame.height / (10*floorPlanScrollView.zoomScale))
        setMinimapMarkerPos()
        if shouldRepaintToOverview()  {
            print("GIEF Overview")
            for subview in floorPlanView.subviews {
                subview.removeFromSuperview()
            }
            self.addPois()
        }else if shouldRepaintToDetailedView() {
            print("GIEF Detail")
            for subview in floorPlanView.subviews {
                subview.subviews[0].removeFromSuperview()
                repaintView(view: subview, standardImage: false)
            }
        }
        lastZoomLevel = self.floorPlanScrollView.zoomScale
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        setMinimapMarkerPos()
    }
    
    func setMinimapMarkerPos(){
        var tmpX = floorPlanScrollView.contentOffset.x / (11*floorPlanScrollView.zoomScale)
        var tmpY = (floorPlanScrollView.contentOffset.y+44.0) / (11*floorPlanScrollView.zoomScale)
        if tmpX < 0 {
            tmpX = 0
        }
        if tmpX + minimapCurrentView.frame.width > minimapView.frame.width {
            tmpX = minimapView.frame.width - minimapCurrentView.frame.width
        }
        if tmpY < 0 {
            tmpY = 0
        }
        if tmpY + minimapCurrentView.frame.height > minimapView.frame.height {
            tmpY = minimapView.frame.height - minimapCurrentView.frame.height
        }
        minimapCurrentView.frame.origin = CGPoint(x: tmpX, y: tmpY)
    }
    
    func getPoiImageUrl(_ type: String) -> UIImage{
        if type == "TEXT" {
            return UIImage(named: "TextIcon")!
        }else if  type == "PHOTO" {
            return UIImage(named: "ImageIcon")!
        }else if type == "DRAWING" {
            return UIImage(named: "DrawingIcon")!
        }else{
            //TODO: Change this to the '...' icon, whatever it is called
            return UIImage(named: "TextIcon")!
        }
    }

    func repaintView(view: UIView, standardImage: Bool){
        var url: String
        //print("view: \(view)")
        if(standardImage){
            let image: UIImage = getPoiImageUrl((self.canaryModel.getMessage(view.tag)?.type.rawValue)!)
            self.addPoiView(view: view, image: image)
        } else {
            //print(self.canaryModel.getClosestLibrary().getFloor().messages.count)
            let message = self.canaryModel.getMessage(view.tag)
            //print("Message: \(message)")
            //print("Downloading from url: \((message?.urlToMessage)!)")
            url = (message?.urlToMessage)!
            canaryModel.downloadImageFromFirebase(url, completion: {data in
                let detailedImage: UIImage = data
                self.addPoiView(view: view, image:detailedImage)
            })
        }

    }

    func addPoiView(view: UIView, image: UIImage){
        let tmpImageWidth:CGFloat = 56
        let tmpImageHeight:CGFloat = 56
        var tmpOrigin = CGPoint(x: (view.frame.width - tmpImageWidth)/2, y: (view.frame.width - tmpImageWidth)/2)
        print("origin: \(tmpOrigin)")
        var tmpImg: UIImageView = UIImageView.init(frame: CGRect(origin: tmpOrigin, size: CGSize(width: tmpImageWidth, height: tmpImageHeight)))
        tmpImg.contentMode = UIViewContentMode.scaleAspectFit
        tmpImg.image = image
        view.addSubview(tmpImg)
    }

    func shouldRepaintToOverview() -> Bool{
        return lastZoomLevel > zoomLevelTreshhold && floorPlanScrollView.zoomScale < zoomLevelTreshhold
    }
    
    func shouldRepaintToDetailedView() -> Bool{
        return lastZoomLevel < zoomLevelTreshhold && floorPlanScrollView.zoomScale > zoomLevelTreshhold
    }
    
    func setupFirebaseMessageObserver(){
        //Clear Messages
        self.canaryModel.getClosestLibrary().getFloor().messages = Set<Message>()
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day], from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        let dateString = "\(year!)-\(month!)-\(day!)"
        
        let path = "Library/\(self.canaryModel.getClosestLibrary().name)/floors/\(self.canaryModel.getClosestLibrary().getFloor().name)/messages/\(dateString)"
        let dbReference = Database.database().reference().child(path)
        
        dbReference.observe(DataEventType.value, with:{(snapshot) in
            if snapshot.childrenCount > 0 {
                for msgs in snapshot.children.allObjects as! [DataSnapshot] {
                    let messageObject = msgs.value as? [String: String]
                    let msgX = (messageObject? ["x"] as NSString?)!.floatValue
                    let msgY = (messageObject? ["y"] as NSString?)!.floatValue
                    let msgID = Int((messageObject?["id"])!)!
                    let msgURL = messageObject?["url"]
                    let msgTypeStr = messageObject?["type"]
                    var msgType = MessageType.DRAWING
                    if msgTypeStr == "TEXT" {
                        msgType = MessageType.TEXT
                    }else if msgTypeStr == "DRAWING"{
                        msgType = MessageType.DRAWING
                    }else if msgTypeStr == "PHOTO" {
                        msgType = MessageType.PHOTO
                    }
                    //Add messages from snapshot
                    let tmpMsg = Message(x: msgX, y: msgY, url: msgURL!, id: msgID, type: msgType)
                    self.canaryModel.getClosestLibrary().getFloor().messages.insert(tmpMsg)
                    //print("Added message with ID: \(msgID)")
                    //print("Size of messages: \(self.canaryModel.getClosestLibrary().getFloor().messages.count)")
                    self.addPois()
                }
            }
        })
    }

}

