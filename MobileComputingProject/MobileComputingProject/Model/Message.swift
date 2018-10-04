//
//  Message.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-09-28.
//  Copyright © 2018 CIU196. All rights reserved.
//

import Foundation

class Message {
    var x: Float
    var y: Float
    var urlToMessage: String
    let id: Int
    
    init(x: Float, y: Float, url:String, id: Int){
        self.x = x
        self.y = y
        self.urlToMessage = url
        self.id = id
    }
}
