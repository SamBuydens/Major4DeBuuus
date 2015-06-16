//
//  GMapViewController.swift
//  DeBuuus
//
//  Created by Sam Buydens on 15/06/15.
//  Copyright (c) 2015 Devine. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
import Socket_IO_Client_Swift

class GMapViewController: BusViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let socket = SocketIOClient(socketURL: "https://guarded-taiga-6026.herokuapp.com")
    
    let optionsHolder = OptionsView()
    let mapView = MapView()
    
    var peopleMarkers:Array<BusMarker>?
    var challengeMarkers:Array<BusMarker>?
    
    var roll = "undefined"
    var goal = "Carry"
    
    var belBusMarker:BusMarker?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peopleMarkers = Array<BusMarker>()
        self.challengeMarkers = Array<BusMarker>()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.mapView.delegate = self
        self.view = self.mapView
        
        socketFunctions()
        rollSelection()
    }
    
    func rollSelection(){
        self.view.addSubview(optionsHolder)
        optionsHolder.styleForBelBusRoleStyle()
        optionsHolder.a.addTarget(self, action: "choiceHandler:", forControlEvents: UIControlEvents.TouchUpInside)
        optionsHolder.b.addTarget(self, action: "choiceHandler:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func choiceHandler(sender:UIButton){
        if(sender.tag == 1){
            self.roll = "driver"
            driver()
        }
        if(sender.tag == 2){
            self.roll = "client"
            client()
        }
    }
    
    func socketFunctions(){
        self.socket.connect()
        self.socket.on("connect") {data, ack in
            println("socket connected")
        }
        //RemovePersonMarker
        self.socket.on("removePersons") {data, ack in
            let sid:NSString = data!.valueForKey("sid")!.objectAtIndex(0) as! NSString
            if(self.locationManager.deleteMarker(sid as String, arr: self.peopleMarkers!) >= 0){
                var index = self.locationManager.deleteMarker(sid as String, arr: self.peopleMarkers!)
                self.peopleMarkers?[index].map = GMSMapView()
                self.peopleMarkers?.removeAtIndex(index)
            }
            
            println(self.peopleMarkers!)
        }
        //RemoveChallengeMarker
        self.socket.on("removecChallengeMarkers") {data, ack in
            let sid:NSString = data!.valueForKey("sid")!.objectAtIndex(0) as! NSString
            if(self.locationManager.deleteMarker(sid as String, arr: self.challengeMarkers!) >= 0){
                var index = self.locationManager.deleteMarker(sid as String, arr: self.challengeMarkers!)
                
                self.challengeMarkers?[index].map = GMSMapView()
                self.challengeMarkers?.removeAtIndex(index)
            }
            
            println(self.challengeMarkers!)
        }
        // logger: self.socket.onAny {println("Got event: \($0.event), with items: \($0.items)")}
    }
    
    func updateLocation(data:NSArray){
        let sid:NSString = data.valueForKey("sid")!.objectAtIndex(0) as! NSString
        let lat:Double = data.valueForKey("lat")!.objectAtIndex(0) as! Double
        let long:Double = data.valueForKey("long")!.objectAtIndex(0) as! Double
        
        var doesContain = self.peopleMarkers!.filter( { (marker: BusMarker) -> Bool in
            return marker.sid == sid as? String
        })
        
        var newCoord = CLLocationCoordinate2DMake(lat, long)
        
        if(doesContain.count > 0){
            doesContain[0].position = newCoord
            doesContain[0].map = GMSMapView()
            doesContain[0].map = self.mapView
        }else{
            var newMarker = BusMarker(position: newCoord, sid: sid as! String)
            newMarker.map = self.mapView
            self.peopleMarkers?.append(newMarker)
        }
        if(doesContain.count > 0){
            if(doesContain[0].sid != self.socket.sid){
                if(self.locationManager.checkDistance(newCoord, mapView: self.mapView)){
                    println("we zijn samen <3")
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var long = manager.location.coordinate.longitude;
        var lat = manager.location.coordinate.latitude;
        if(self.roll == "client" && (self.socket.sid) != nil){
            self.socket.emit("updateClientLocation", self.mapView.myLocation.coordinate.longitude, self.mapView.myLocation.coordinate.latitude, self.socket.sid!)
        }
        if(self.roll == "driver" && (self.socket.sid) != nil){
            self.socket.emit("updateDriverLocation", self.mapView.myLocation.coordinate.longitude, self.mapView.myLocation.coordinate.latitude, self.socket.sid!)
        }
    }
    ///////////////////////<DRIVER>///////////////////////////
    func driver(){
        self.socket.on("updateClientsLocation") {data, ack in
            self.updateLocation(data!)
        }
        self.socket.on("updateBelBusMarkers") {data, ack in
            self.updateBelBusMarker(data!)
        }
    }
    
    func updateBelBusMarker(data:NSArray){
        let sid:NSString = data.valueForKey("sid")!.objectAtIndex(0) as! NSString
        let lat:Double = data.valueForKey("lat")!.objectAtIndex(0) as! Double
        let long:Double = data.valueForKey("long")!.objectAtIndex(0) as! Double
        
        var doesContain = self.challengeMarkers!.filter( { (marker: BusMarker) -> Bool in
            return marker.sid == sid as? String
        })
        
        var newCoord = CLLocationCoordinate2DMake(lat, long)
        
        if(doesContain.count > 0){
            doesContain[0].position = newCoord
            doesContain[0].map = GMSMapView()
            doesContain[0].map = self.mapView
        }else{
            var newMarker = BusMarker(position: newCoord, sid: sid as! String)
            newMarker.map = self.mapView
            self.challengeMarkers?.append(newMarker)
        }
        if(doesContain.count > 0){
            if(doesContain[0].sid != self.socket.sid){
                if(self.locationManager.checkDistance(newCoord, mapView: self.mapView)){
                    println("we zijn samen <3")
                }
            }
        }
    }
    ///////////////////////</DRIVER>//////////////////////////
    
    ///////////////////////<CLIENT>///////////////////////////
    
    func client(){
        optionsHolder.styleForBelBusGoalStyle()
        
        optionsHolder.c.addTarget(self, action: "optionHandler:", forControlEvents: UIControlEvents.TouchUpInside)
        optionsHolder.d.addTarget(self, action: "optionHandler:", forControlEvents: UIControlEvents.TouchUpInside)
        optionsHolder.e.addTarget(self, action: "optionHandler:", forControlEvents: UIControlEvents.TouchUpInside)
        optionsHolder.cancel.addTarget(self, action: "cancelGoalHandler", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.socket.on("updateDriversLocation") {data, ack in
            self.updateLocation(data!)
        }
    }
    
    func optionHandler(sender:UIButton){
        if(sender.tag == 3){
            self.goal = "Carry"
        }
        if(sender.tag == 4){
            self.goal = "Food"
        }
        if(sender.tag == 5){
            self.goal = "Drink"
        }
        
        var doesContain = self.challengeMarkers!.filter( { (marker: BusMarker) -> Bool in
            return marker.sid == self.socket.sid!
        })
        if(doesContain.count > 0){
            mapView(mapView, didLongPressAtCoordinate: doesContain[0].position)
        }
    }
    
    func mapView(mapView: GMSMapView!, didLongPressAtCoordinate coordinate: CLLocationCoordinate2D) {
        
        if(self.roll != "undefined" && (self.socket.sid) != nil){
            
            let newCoord = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
            
            var doesContain = self.challengeMarkers!.filter( { (marker: BusMarker) -> Bool in
                return marker.sid == self.socket.sid!
            })
            if(doesContain.count > 0){
                doesContain[0].position = newCoord
                doesContain[0].title = self.goal
            }else{
                var newMarker = BusMarker(position: newCoord, sid: self.socket.sid!) //bELbUS todo: goal
                newMarker.map = self.mapView
                newMarker.title = self.goal
                self.challengeMarkers?.append(newMarker)
            }
            
            self.socket.emit("updateBelBusMarker", coordinate.longitude, coordinate.latitude, self.socket.sid!, self.goal)
        }
    }
    
    func cancelGoalHandler(){
        
        self.roll = "undefined"
        
        if((self.socket.sid) != nil){
            self.locationManager.deleteMarker(self.socket.sid!, arr: self.challengeMarkers!)
        }
        
        if((self.socket.sid) != nil){
            self.socket.emit("removePerson", self.socket.sid!)
            self.socket.emit("removecChallengeMarker", self.socket.sid!)
        }
        
        self.socket.off("updateDriversLocation")
        
        optionsHolder.styleForBelBusRoleStyle()
        
    }
    
    ///////////////////////</CLIENT>//////////////////////////
    
    
    
    override func viewWillDisappear(animated: Bool) {
        
        if((self.socket.sid) != nil){
            self.socket.emit("removePerson", self.socket.sid!)
            self.socket.emit("removecChallengeMarker", self.socket.sid!)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}