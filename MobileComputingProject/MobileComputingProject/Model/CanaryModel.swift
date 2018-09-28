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

class CanaryModel {
    static let sharedInstance  = CanaryModel()
    
    var libraries = [Int: Library]()
    var createdLibraries = 0
    
    func getLibrary(byID id:Int) -> Library?{
        return libraries[id]
    }
    
    func createLibrary(name: String){
        let tmpLibrary = Library(name: name, id: createdLibraries)
        libraries[createdLibraries] = tmpLibrary
        createdLibraries += 1
    }
    
    func deleteLibrary(){
        //TODO
    }
    
    
    
    private init() {}
}
