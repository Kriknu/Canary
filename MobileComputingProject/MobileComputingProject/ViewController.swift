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
    
    
    var zoomLevelTreshhold: CGFloat = 1.5
    var lastZoomLevel: CGFloat = 0.0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///////////////////////
        // ***************** //
        // *** LOAD DATA *** //
        // ***************** //
        ///////////////////////
        
        // 1. Load floor plan
        let floorImageURL = canaryModel.getClosestLibrary().getFloor().urlToFloorPlan
        
        // 2. Fetch message references from database
        let dbMessages = [Message]()
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day], from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        let dateString = "\(year!)-\(month!)-\(day!)"
        
        //let path = "messages/\(self.canaryModel.getClosestLibrary().name)/\(self.canaryModel.getClosestLibrary().getFloor().name)/\(dateString)"
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
                    if self.canaryModel.getMessage(msgID) == nil {
                        self.canaryModel.getClosestLibrary().getFloor().messages.insert(Message(x: msgX, y: msgY, url: msgURL!, id: msgID, type: msgType))
                    }
                }
            }
        })
        
        // 3. Load messages
        for message in canaryModel.getClosestLibrary().getFloor().messages {
            print("Message X: \(message.x) || Message Y: \(message.y)")
            print("URL: \(message.urlToMessage)")
            self.addPoi(x: CGFloat(message.x), y: CGFloat(message.y), tag: message.id, type: message.type)
        }
        print(canaryModel.getClosestLibrary().getFloor().messages.count)
        
        // Scroll level specification
        self.floorPlanScrollView.minimumZoomScale = 0.4
        self.floorPlanScrollView.maximumZoomScale = 2.0
        
        // Setup gesture recognition
        let addPinRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addMessage))
        floorPlanView.isUserInteractionEnabled = true
        floorPlanView.addGestureRecognizer(addPinRecognizer)
        self.floorPlanView.sd_setImage(with: canaryModel.downloadImageReferenceFromFirebase("floorplans/Floorplan_v3.png"))
        
        // Test query in order to write to database
        let dbQuery: NSDictionary = [
            "name": "Lol",
            "long":10,
            "lat":5,
            "floors":[
                "name": 1,
                "content":
                "reference to image",
                "messages":[
                    "x": 0,
                    "y": 0,
                    "content": "Reference to drawing",
                    "user": "userID"
                ]
            ]
        ]
        //canaryModel.writeToDatabase(path: "Library/Gluggen", value: dbQuery)
        //TODO: Make an async call
        let response = canaryModel.readFromDatabase(path: "Library", completion:{data in
            // Here we set the values when we need to create gui items
            print(data)
        })
        setupTrashcan()
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
    
    func addPoi(x: CGFloat, y: CGFloat, tag: Int, type: MessageType){
        let url = getPoiImageUrl(type.rawValue)
        var image: UIImage = UIImage()
        canaryModel.downloadImageFromFirebase(url, completion: {data in
            image = data
            let view = UIImageView(frame: CGRect(x: x, y: y, width: 48, height: 48))
            view.image = image
            view.tag = tag
            // Add a gesture recognizer to every created pin to move it
            let movePinRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.poiTapped))
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(movePinRecognizer)

            //Add drop shadow to POI
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 1)
            view.layer.shadowOpacity = 0.5
            view.layer.shadowRadius = 1.0
            view.clipsToBounds = false
            
            print("View X: \(view.frame.origin.x) || View Y: \(view.frame.origin.y)")
            self.floorPlanView.addSubview(view)
            UIImpactFeedbackGenerator.init(style: UIImpactFeedbackStyle.heavy).impactOccurred()
        })
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
    
    
    
    func createPopOver(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Text", style: UIAlertActionStyle.default, handler:
            {(alert: UIAlertAction!) in self.segueToTextTool()}))
        alert.addAction(UIAlertAction(title: "Paint", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.segueToPaintTool()}))
        alert.addAction(UIAlertAction(title: "Photo", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.segueToCameraTool()}))
        present(alert, animated: true)
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
        //print("Zoom done")
        if shouldRepaintToOverview()  {
            print("GIEF Overview")
            for subview in floorPlanView.subviews {
                subview.removeFromSuperview()
                repaintView(view: subview, standardImage: true)
            }
        }else if shouldRepaintToDetailedView() {
            print("GIEF Detail")
            for subview in floorPlanView.subviews {
                subview.removeFromSuperview()
                repaintView(view: subview, standardImage: false)
            }
        }
        lastZoomLevel = self.floorPlanScrollView.zoomScale
    }
    
    func getPoiImageUrl(_ type: String) -> String{
        if type == "TEXT" {
            return "assets/text_bubble.png"
        }else if  type == "PHOTO" {
            return "assets/photo_bubble.png"
        }else if type == "DRAWING" {
            return "assets/drawing_bubble.png"
        }else{
            return "assets/empty_bubble.png"
        }
    }

    func repaintView(view: UIView, standardImage: Bool){
        var url: String
        print("view.tag = \(view.tag)")
        if(standardImage){
            url = getPoiImageUrl((self.canaryModel.getMessage(view.tag)?.type.rawValue)!)
        } else {
            let message = canaryModel.getMessage(view.tag)
            print("Downloading from url: \((message?.urlToMessage)!)")
            url = (message?.urlToMessage)!
        }
        canaryModel.downloadImageFromFirebase(url, completion: {data in
            // Here we set the values when we need to create gui items
            let detailedImage: UIImage = data
            var tmpOrigin = CGPoint(x: view.frame.origin.x, y: view.frame.origin.y)
            print("origin: \(tmpOrigin)")
            var newView = DetailedViewShape(frame: CGRect(origin: tmpOrigin, size: CGSize(width: 80, height: 80)))
            var tmpImg: UIImageView = UIImageView.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 50)))
            tmpImg.contentMode = UIViewContentMode.scaleAspectFit
            tmpImg.image = detailedImage
            newView.backgroundColor = UIColor.clear
            newView.addSubview(tmpImg)
            newView.bringSubview(toFront: tmpImg)
            newView.tag = view.tag
            view.removeFromSuperview()
            self.floorPlanView.addSubview(newView)
            //subview.backgroundColor = UIColor(patternImage: detailedImage)
        })
    }

    func shouldRepaintToOverview() -> Bool{
        return lastZoomLevel > zoomLevelTreshhold && floorPlanScrollView.zoomScale < zoomLevelTreshhold
    }
    
    func shouldRepaintToDetailedView() -> Bool{
        return lastZoomLevel < zoomLevelTreshhold && floorPlanScrollView.zoomScale > zoomLevelTreshhold
    }

}

