//
//  LibraryFloor.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-10-03.
//  Copyright © 2018 CIU196. All rights reserved.
//

import Foundation

class Floor {
    var urlToFloorPlan: String
    var messages: [Message] = []
    let name: String
    
    init(_ name: String, url: String) {
        self.name = name
        self.urlToFloorPlan = url
    }
    
    func addMessage(x: Double, y: Double, url: String){
        messages.append(Message(x: x, y: y, url: url))
    }
}
