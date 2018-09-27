//
//  Library.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-09-26.
//  Copyright © 2018 CIU196. All rights reserved.
//

import Foundation

struct Library {
    
    var name: String
    var nbrOfFloors: Int
    
    
    init(libName: String, floors: Int){
        name = libName
        nbrOfFloors = floors
    }
}
