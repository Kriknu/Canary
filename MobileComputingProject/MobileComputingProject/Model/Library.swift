//
//  Library.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-09-26.
//  Copyright © 2018 CIU196. All rights reserved.
//

import Foundation

class Library {
    
    var name: String
    var id: Int
    var nbrOfFloors: Int{
        get{
            return floorPlans.count
        }
    }
    var floorPlans = [String: String]()
    
    var longitude: Double
    var latitude: Double
    
    init(name: String, id: Int, long: Double, lat: Double){
        self.name = name
        self.id = id
        self.longitude = long
        self.latitude = lat
    }
    
    func addFloorPlan(nameOfFloor: String, urlToPicture: String) -> Bool{
        let oldCount = floorPlans.count
        floorPlans[nameOfFloor] = urlToPicture
        let newCount = floorPlans.count
        return oldCount < newCount
    }
}
