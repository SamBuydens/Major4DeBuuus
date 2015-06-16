//
//  CLLocationManagerExtension.swift
//  DeBuuus
//
//  Created by Sam Buydens on 16/06/15.
//  Copyright (c) 2015 Devine. All rights reserved.
//

import UIKit
import GoogleMaps

extension CLLocationManager {
    func deleteMarker(sid:String, arr:Array<BusMarker>)->Int{
        
        var arr = arr
        
        var doesContain = arr.filter( { (marker: BusMarker) -> Bool in
            
            return marker.sid == sid
        })
        
        if(doesContain.count > 0){println("with a marker")
            println(doesContain[0])
            var index = find(arr, doesContain[0])
            arr.removeAtIndex(index!)
            
            return index!
        }
        
        return -1
    }
    
    func removeObject<T : Equatable>(object: T, inout fromArray array: [T]){
        var index = find(array, object)
        array.removeAtIndex(index!)
    }
    
    func checkDistance(helperLoc:CLLocationCoordinate2D, mapView:MapView)->Bool{
        if((mapView.myLocation) != nil){
            var needingLoc = mapView.myLocation.coordinate
            return GMSGeometryDistance(helperLoc, needingLoc) < 10
        }
        
        return false
    }
}
