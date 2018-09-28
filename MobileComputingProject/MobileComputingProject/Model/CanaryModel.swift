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
        let tmpLibrary = Library(name: name, id: createdLibraries, long: 1.0, lat: 1.0)
        libraries[createdLibraries] = tmpLibrary
        createdLibraries += 1
    }
    
    func deleteLibrary(){
        //TODO
    }
    
    /*
     Untested method
     */
    func getClosestLibrary(lat: Double, long: Double) -> Library?{
        var closestDistanceFound = 100000000000.0
        var closestLibrary: Library?
        for (_, lib) in libraries {
            let deltaLat = pow((lib.latitude - lat), 2)
            let deltaLong = pow((lib.longitude - long), 2)
            let distance = sqrt(deltaLat+deltaLong)
            
            if distance < closestDistanceFound {
                closestDistanceFound = distance
                closestLibrary = lib
            }
        }
        return closestLibrary
    }
    
    
    
    private init() {}
}
