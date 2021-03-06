//
//  CanaryModel.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-09-26.
//  Copyright © 2018 CIU196. All rights reserved.
//


/*
        Singleton instance, a handler for all data
 */
import Foundation
import CoreLocation
import FirebaseDatabase
import FirebaseStorage

class CanaryModel: NSObject, CLLocationManagerDelegate{
    // Singleton "getter"
    static let sharedInstance  = CanaryModel()
    var libraryID = 0;
    let databaseRef = Database.database().reference()
    
    // Information of last position of mainViewController
    var lastPoint: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var lastZoom: CGFloat = 0.0
    
    // Model stuff
    var libraries: [Library] = []
    var currentFloor = 0
    
    // Vars changed for creating message #ShitCodeDontHate
    var latestLongPressXCoord: Float = -1.0
    var latestLongPressYCoord: Float = -1.0
    var latestID = -1;
    
    // lazy meaning that this wont get initialized until value is fetched the first time
    lazy var messageId = getClosestLibrary().getFloor().messages.count
    
    // Connection between a Library and it's UIView (aka, the pin/poi)
    var libraryViews: Dictionary = [UIView: Library]()
    // GPS
    var locationManager: CLLocationManager = CLLocationManager()
    var longitude: Double {
        get{return Double(self.getLocation()?.coordinate.longitude ?? 0)}
    }
    var latitude: Double {
        get{return Double(self.getLocation()?.coordinate.latitude ?? 0)}
    }
    
    // Database
    func writeToDatabase(path: String, value: NSDictionary){
        databaseRef.child(path).setValue(value)
    }

    func readFromDatabase(path: String, completion: @escaping (NSDictionary) -> Void) {
        var dbResponse: NSDictionary?
        let ref = Database.database().reference()
        ref.child(path).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            dbResponse = value
            completion(dbResponse!)
        }) {(error) in
            print(error.localizedDescription)
        }
    }

    func getLibrary(byName name: String) -> Library?{
        for lib in libraries {
            if lib.name == name {return lib}
        }
        return nil
    }
    
    func deleteMessage(_ withId: Int) -> Bool{
        let tmpMsg = getMessage(withId)
        if tmpMsg == nil {
            return false
        }
        getClosestLibrary().getFloor().messages.remove(tmpMsg!)
        //TODO: Remove the message from FIREBASE
        return true;
    }

    func getClosestLibrary() -> Library{
        var closestDistanceFound = 100000000000.0
        for lib in libraries {
            let deltaLat = pow((lib.latitude - latitude), 2)
            let deltaLong = pow((lib.longitude - longitude), 2)
            let distance = sqrt(deltaLat+deltaLong)
            
            if distance < closestDistanceFound {
                closestDistanceFound = distance
                return lib
            }
        }
        return libraries[0]
    }
    
    func getLocation() -> CLLocation? {
        return self.locationManager.location
    }
    
    func downloadImageFromFirebase(_ path: String, completion: @escaping (UIImage) -> Void) {
        let storageReference: StorageReference = downloadImageReferenceFromFirebase(path)
        storageReference.getData(maxSize: 50*1024*1024) {data, error in
            if let error = error {
                print(error)
            } else {
                let image = UIImage(data: data!)
                completion(image!)
            }
        }
    }

    func downloadImageReferenceFromFirebase(_ path: String) -> StorageReference {
        let storage = Storage.storage()
        let reference = storage.reference()
        let imageReference = reference.child(path)
        return imageReference
    }

    func uploadImageToFirebase(_ imageName: String, img: UIImage?){
        do {
            let storage = Storage.storage()
            let storageReference = storage.reference()
            let fileName = imageName
            
            let image = img
            let jpgImage: Data? = UIImageJPEGRepresentation(image!, 1.0)
            let imageRef = storageReference.child(fileName)
            _ = imageRef.putData(jpgImage ?? Data(), metadata:nil, completion:{(metadata,error) in
            })
        }
    }

    func getImageName() -> String {
        let prefix = UIDevice.current.identifierForVendor!.uuidString
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        let suffix = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        return "images/\(prefix)-\(suffix).jpg"
    }

    func addMessage(imageName: String, type: MessageType){
        let tmpMessage = getClosestLibrary().getFloor().addMessage(x: latestLongPressXCoord, y: latestLongPressYCoord, url: imageName, id: latestID, type: type)
        let info: NSDictionary = ["id": String(tmpMessage.id),
                    "x": String(tmpMessage.x),
                    "y": String(tmpMessage.y),
                    "url": tmpMessage.urlToMessage,
                    "type": type.rawValue]
        //Create a unique entry path
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day], from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        let dateString = "\(year!)-\(month!)-\(day!)"
        
        let uniqueID = databaseRef.child("Library/\(getClosestLibrary().name)/floors/\(getClosestLibrary().getFloor().name)/messages/\(dateString)").childByAutoId().key
        
        let tmpPath = "Library/\(getClosestLibrary().name)/floors/\(getClosestLibrary().getFloor().name)/messages/\(dateString)/\(uniqueID!)"
        writeToDatabase(path: tmpPath, value: info)
    }

    func addFloor(name: String, data: String){
        getClosestLibrary().addFloor(nameOfFloor: name, urlToPicture: data)
    }
    
    func addLibrary(name: String, lat: Double, lon: Double){
        let tmpLibrary = Library(name: name, id: libraryID, long: lon, lat: lat)
        libraries.append(tmpLibrary)
        libraryID += 1
    }

    func getMessage(_ byId: Int) -> Message?{
        let msg: Message? = nil
        for message in getClosestLibrary().getFloor().messages {
            if message.id == byId{
                return message
            }
        }
        return msg
    }
    
    // *** PRIVATE CONSTRUCTOR *** //
    
    private override init() {
        super.init()
        // Setup location manager for retrieving GPS position
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }else{
            print("Location services not enabled")
        }
        
        // *** DUMMY VALUES BEGIN *** //
        addLibrary(name: "Kuggen", lat: 0.0, lon: 0.0)
        addFloor(name: "Andra Våningen", data: "https://firebasestorage.googleapis.com/v0/b/canary-e717d.appspot.com/o/floorplans%2FFloorplan_v4.png?alt=media&token=4f9736ce-288d-41e9-bf17-eb1c2268e50b")
        // **** DUMMY VALUES END **** //
    }
}
