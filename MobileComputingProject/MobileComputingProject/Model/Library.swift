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
    
    
    init(name: String, id: Int){
        self.name = name
        self.id = id;
    }
    
    func addFloorPlan(nameOfFloor: String, urlToPicture: String) -> Bool{
        let oldCount = floorPlans.count
        floorPlans[nameOfFloor] = urlToPicture
        let newCount = floorPlans.count
        return oldCount < newCount
    }
}
