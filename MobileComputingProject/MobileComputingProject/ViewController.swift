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
    @IBOutlet weak var titleLabel: UILabel!
    
    
    // Singleton Model
    var canaryModel: CanaryModel = CanaryModel.sharedInstance

    // Trashcan
    var trashCanView:UIImageView = UIImageView()
    
    // Minimap
    @IBOutlet weak var minimapView: UIView!
    var minimapCurrentView: UIImageView!
    
    // Zoom levels
    var zoomLevelTreshhold: CGFloat = 1.5
    var lastZoomLevel: CGFloat = 0.0
    
    // Moving pins
    // Offset is stored when gesture began, but same for every change of the gesture
    var movePoiOffsetX:CGFloat = 0
    var movePoiOffsetY:CGFloat = 0
    
    // Temporary button for showing where user are creating a POI
    var placeholderPOI: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 64, height: 76))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup Floorplan, Library Name, and scrollview
        let floorImageURL = canaryModel.getClosestLibrary().getFloor().urlToFloorPlan
        let addPinRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addMessage))
        self.floorPlanView.isUserInteractionEnabled = true
        self.floorPlanView.addGestureRecognizer(addPinRecognizer)
        self.floorPlanView.sd_setImage(with: canaryModel.downloadImageReferenceFromFirebase("floorplans/Floorplan_v4.png"))
        self.floorPlanScrollView.minimumZoomScale = 0.4
        self.floorPlanScrollView.maximumZoomScale = 2.0
        
        titleLabel.layer.shadowColor = UIColor.white.cgColor
        titleLabel.layer.shadowRadius = 4.0
        titleLabel.layer.shadowOpacity = 1.0
        titleLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        titleLabel.layer.masksToBounds = false

        
        
        // 2. Setup Message Observer
        self.setupFirebaseMessageObserver()
        
        // 3. Setup Minimap
        self.setupMinimap()
        
        // 4. Setup trashcan
        self.setupTrashcan()
        
        // 5. Placeholder Pin
        self.floorPlanView.addSubview(placeholderPOI)
        if let tmpImg = UIImage(named: "MoreBubble")?.image(alpha: 0.3) {
            self.placeholderPOI.backgroundColor = UIColor(patternImage: tmpImg)
        }
        floorPlanView.bringSubview(toFront: placeholderPOI)
        placeholderPOI.isHidden = true
    }


    /*
    Method called by the LongTapRecognizer on the floorplanview. Saves the coordinates of the long tap and creates a
    unique ID in the canarymodel, and when a message is actually created (e.g. some painting has been done) the
    PaintViewController can tell the model to create a message and the X,Y coords are available. This should be
    done using bundle information since storing a temporary variable is Bad. After saving the coordinates and the ID,
    it triggers a popover meny where the user can choose between painting, taking a picture or writing a message.
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
            
            // Place temporary marker to show where user is creating a POI
            print("CRASHING 1?")
            self.placeholderPOI.frame.origin = point
            self.placeholderPOI.isHidden = false
            print(point)
            print(self.placeholderPOI.frame.origin)
            // Zoom in to new point
            self.floorPlanScrollView.zoom(to: self.placeholderPOI.frame, animated: true)
            print("CRASHING 2?")
            
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

    /*
     A POI (Point of interest) is the graphical representation of a Message. This method is called for each message that should
     painted out of the map. It takes care of adding the proper gesture recognizers.
     */
    func addPois(){
        let msgs = self.canaryModel.getClosestLibrary().getFloor().messages
        for message in msgs {
            // Positioning
            let x = CGFloat(message.x)
            let y = CGFloat(message.y)
            
            // Size
            let bubbleWidth:CGFloat = 72
            let bubbleHeight:CGFloat = 84
            let iconWidth:CGFloat = 48
            let iconHeight:CGFloat = 48
            
            // Graphic Component
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
            
            // Add a gesture recognizer to focus on a tip (double tap)
            let focusRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.focusOnPOI))
            focusRecognizer.numberOfTapsRequired = 1
            bubble.addGestureRecognizer(focusRecognizer)
            print("addpois added view with tag: \(bubble.tag)")
            bubble.addSubview(view)
            self.floorPlanView.addSubview(bubble)
            UIImpactFeedbackGenerator.init(style: UIImpactFeedbackStyle.heavy).impactOccurred()
        }
    }
    
    @objc func focusOnPOI(_ sender: UITapGestureRecognizer){
        if let senderView = sender.view {
            floorPlanScrollView.zoom(to: senderView.frame, animated: true)
        }
    }

    /*
     Method called upon when a long press occurs on a POI, i.e. a user wants to move the POI. If the user drags the POI and releases it over
     the trashcan, the POI (and message) is removed. TODO: Remove the message from the DB
     */
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
        UIImpactFeedbackGenerator.init(style: UIImpactFeedbackStyle.heavy).impactOccurred()
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor(displayP3Red: 7.0/255, green: 80.0/255, blue: 90.0/255, alpha: 1)
        alert.addAction(UIAlertAction(title: "Text", style: UIAlertActionStyle.default, handler:
            {(alert: UIAlertAction!) in self.segueToTextTool()}))
        alert.addAction(UIAlertAction(title: "Paint", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.segueToPaintTool()}))
        alert.addAction(UIAlertAction(title: "Photo", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.segueToCameraTool()}))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {(alert: UIAlertAction!) in self.alertControllerBackgroundTapped()}))
        present(alert, animated: true)
    }
    
    @objc func alertControllerBackgroundTapped() {
        //TODO: Add functionality to dismiss temp-POI
        placeholderPOI.isHidden = true
        print("TAP TAP TAP !!! CLICK CLICK CLICK!!!")
    }
    
    /*
     Transations to other viewcontrollers
     */
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
        let iconWidth:CGFloat = 48.0
        let iconHeight:CGFloat = 48.0
        let viewX = (UIScreen.main.bounds.width / 2) - (iconWidth / 2)
        let viewY = UIScreen.main.bounds.height - (iconHeight * 1.5)
        trashCanView = UIImageView(frame: CGRect(x: viewX, y: viewY, width: 48, height: 48))
        trashCanView.image = UIImage(named: "TrashIcon")
        
        //trashCanView.layer.backgroundColor = UIColor(red: 236.0/255, green: 253.0/255, blue: 255.0/255, alpha: 0.5).cgColor
        //trashCanView.layer.borderColor = UIColor(displayP3Red: 102.0/255, green: 170.0/255, blue: 179.0/255, alpha: 1).cgColor
        //trashCanView.layer.borderWidth = 1.0
        //trashCanView.layer.cornerRadius = 4.0
        //minimapCurrentView.layer.borderColor = UIColor(displayP3Red: 7.0/255, green: 80.0/255, blue: 90.0/255, alpha: 1).cgColor

        view.addSubview(trashCanView)
        trashCanView.isHidden = true
        trashCanView.isUserInteractionEnabled = false
    }
    
    /*
     Called upon when a zooming events occurs
     */
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        //print("Zoomlevel: \(floorPlanScrollView.zoomScale)")
        let tmpWidth = min((self.view.frame.width / (10*floorPlanScrollView.zoomScale)), self.minimapView.frame.width)
        let tmpHeight = min((self.view.frame.height / (10*floorPlanScrollView.zoomScale)), self.minimapView.frame.height)
        minimapCurrentView.frame.size = CGSize(width: tmpWidth, height: tmpHeight)
        setMinimapMarkerPos()
        if shouldRepaintToOverview()  {
            print("GIEF Overview")
            for subview in floorPlanView.subviews {
                if subview.subviews.count > 0 {
                    subview.removeFromSuperview()
                }
            }
            print("scrollViewDidZoom called upon addPois")
            self.addPois()
        }else if shouldRepaintToDetailedView() {
            print("GIEF Detail")
            for subview in floorPlanView.subviews {
                if subview.subviews.count > 0 {
                    subview.subviews[0].removeFromSuperview()
                    repaintView(view: subview, standardImage: false)
                }
            }
        }
        lastZoomLevel = self.floorPlanScrollView.zoomScale
    }

    /*
     Called upon when panning occurs in the floorplanscrollview
    */
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        setMinimapMarkerPos()
    }
    
    /*
     Draws the red marker on the minimap dependant on where the user is currently looking at the map
     */
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
            if let url = message?.urlToMessage {
                self.canaryModel.downloadImageFromFirebase(url, completion: {data in
                    let detailedImage: UIImage = data
                    self.addPoiView(view: view, image:detailedImage)
                })
            }
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
        print("addPoiView adding view with tag: \(view.tag)")
        view.addSubview(tmpImg)
    }

    func shouldRepaintToOverview() -> Bool{
        return lastZoomLevel > zoomLevelTreshhold && floorPlanScrollView.zoomScale < zoomLevelTreshhold
    }
    
    func shouldRepaintToDetailedView() -> Bool{
        return lastZoomLevel < zoomLevelTreshhold && floorPlanScrollView.zoomScale > zoomLevelTreshhold
    }
    
    func setupMinimap(){
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
        minimapView.layer.borderColor = UIColor(displayP3Red: 102.0/255, green: 170.0/255, blue: 179.0/255, alpha: 1).cgColor
        minimapView.layer.cornerRadius = 4.0
        
        // Minimap marker
        print(self.view.frame.width)
        print(self.view.frame.height)
        let tmpWidth = self.view.frame.width / (11*floorPlanScrollView.zoomScale)
        let tmpHeight = self.view.frame.height / (11*floorPlanScrollView.zoomScale)
        minimapCurrentView = UIImageView(frame: CGRect(x: 0, y: 0, width: tmpWidth, height: tmpHeight))
        minimapCurrentView.layer.cornerRadius = 4.0
        minimapCurrentView.backgroundColor = UIColor(red: 236.0/255, green: 253.0/255, blue: 255.0/255, alpha: 0.5)
        minimapCurrentView.layer.borderWidth = 1.0
        minimapCurrentView.layer.borderColor = UIColor(displayP3Red: 7.0/255, green: 80.0/255, blue: 90.0/255, alpha: 1).cgColor

        
        minimapView.addSubview(imageView)
        minimapView.addSubview(minimapCurrentView)
        minimapView.isUserInteractionEnabled = false
    }
    
    func setupFirebaseMessageObserver(){
        //Clear Messages
        print("Message Count: \(self.canaryModel.getClosestLibrary().getFloor().messages.count)")
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
                }
                print("Snapshot calling upon addPois")
                self.addPois()
            }
        })
    }

}

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

