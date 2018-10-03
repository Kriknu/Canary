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
            return floors.count
        }
    }
    var floors: [Floor] = []
    
    var longitude: Double
    var latitude: Double
    
    init(name: String, id: Int, long: Double, lat: Double){
        self.name = name
        self.id = id
        self.longitude = long
        self.latitude = lat
    }
    
    func addFloor(nameOfFloor: String, urlToPicture: String) -> Bool{
        let oldCount = floors.count
        floors.append(Floor(nameOfFloor, url: urlToPicture))
        let newCount = floors.count
        return oldCount < newCount
    }
    
    func getFloor() -> Floor{
        return floors[0] //Dummy value for now :TODO
    }
    
    
}
