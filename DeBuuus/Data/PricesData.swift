//
//  LocationData.swift
//  CosyYou
//
//  Created by Sam Buydens on 9/03/15.
//  Copyright (c) 2015 Devine. All rights reserved.
//

import UIKit

class LocationData: NSObject {
    let name:String
    let latitude:Double
    let longitude:Double
    let pictureArray:Array<String>?
    let locationdescription:String
    
    init(name:String, latitude:Double, longitude:Double, pictureArray:Array<String>, locationdescription:String){
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.pictureArray = pictureArray
        self.locationdescription = locationdescription
    }
    
    override var description:String{
        return "[Data]\(name)"
    }
}
