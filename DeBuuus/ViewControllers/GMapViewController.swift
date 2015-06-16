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
    let rollFrame = UIView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.height-100, UIScreen.mainScreen().bounds.width, 100))
    var mapView = GMSMapView(frame: UIScreen.mainScreen().bounds)
    var southWest:CLLocationCoordinate2D?
    var northEast:CLLocationCoordinate2D?
    var camera:GMSCameraPosition?
    var markers:Array<BusMarker>?
    
    var roll = "undefined"
    var need = "dragen"
    
    var belBusMarker:BusMarker?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.markers = Array<BusMarker>()
        placeMapView()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        rollSelection()
        socketFunctions()
    }
    
    override func viewWillDisappear(animated: Bool) {
        if((self.socket.sid) != nil){
            self.socket.emit("removePerson", self.socket.sid!)
            self.socket.emit("removeBelBus", self.socket.sid! + "belBus")
        }
    }
    
    func rollSelection(){
        rollFrame.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(rollFrame)
        
        var helperButton = UIButton(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width/2, 100))
        helperButton.backgroundColor = BusColors().rood
        rollFrame.addSubview(helperButton)
        helperButton.addTarget(self, action: "rollHandler:", forControlEvents: UIControlEvents.TouchUpInside)
        helperButton.tag = 1
        
        var needingButton = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width/2, 0, UIScreen.mainScreen().bounds.width/2, 100))
        needingButton.backgroundColor = BusColors().blauw
        needingButton.tag = 2
        rollFrame.addSubview(needingButton)
        needingButton.addTarget(self, action: "rollHandler:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func rollHandler(sender:UIButton){
        println(self.roll)
        for subview in self.rollFrame.subviews as! [UIView] {
            subview.removeFromSuperview()
        }
        if(sender.tag == 1){
            //helper
            self.roll = "helper"
            self.socket.off("updateHelperLocation")
            self.socket.on("updateNeedLocation") {data, ack in
                self.updateLocation(data!)
                return
            }
        }else{
            //need
            self.socket.off("updateNeedLocation")
            self.socket.on("updateHelperLocation") {data, ack in
                self.updateLocation(data!)
                return
            }
            
            self.roll = "need"
            self.rollFrame.backgroundColor = UIColor.whiteColor()
            self.view.addSubview(rollFrame)
            
            var keuze1 = UIButton(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width/4, 100))
            keuze1.backgroundColor = BusColors().blauw
            keuze1.tag = 1
            self.rollFrame.addSubview(keuze1)
            keuze1.addTarget(self, action: "choiseHandler:", forControlEvents: UIControlEvents.TouchUpInside)
            
            var keuze2 = UIButton(frame: CGRectMake(keuze1.frame.width, 0, UIScreen.mainScreen().bounds.width/4, 100))
            keuze2.backgroundColor = BusColors().geel
            self.rollFrame.addSubview(keuze2)
            keuze2.tag = 2
            keuze2.addTarget(self, action: "choiseHandler:", forControlEvents: UIControlEvents.TouchUpInside)
            
            var keuze3 = UIButton(frame: CGRectMake(keuze1.frame.width*2, 0, UIScreen.mainScreen().bounds.width/4, 100))
            keuze3.backgroundColor = BusColors().wit
            self.rollFrame.addSubview(keuze3)
            keuze3.tag = 3
            keuze3.addTarget(self, action: "choiseHandler:", forControlEvents: UIControlEvents.TouchUpInside)
            
            var cancel = UIButton(frame: CGRectMake(keuze1.frame.width*3, 0, UIScreen.mainScreen().bounds.width/4, 100))
            cancel.backgroundColor = BusColors().rood
            self.rollFrame.addSubview(cancel)
            cancel.tag = 4
            cancel.addTarget(self, action: "cancelHandler", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    func choiseHandler(sender:UIButton){
        println(sender.tag)
        if(sender.tag == 1){
            self.need = "friet"
        }
        if(sender.tag == 2){
            self.need = "drank"
        }
        if(sender.tag == 3){
            self.need = "dragen"
        }
    }
    
    func cancelHandler(){
        for subview in self.rollFrame.subviews as! [UIView] {
            subview.removeFromSuperview()
        }
        rollSelection()
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if(self.roll == "need"){
            if((self.belBusMarker) == nil){
                self.belBusMarker = BusMarker(position: coordinate, sid: self.socket.sid! + "belBus")
                self.belBusMarker?.appearAnimation = kGMSMarkerAnimationPop
            }else{
                belBusMarker!.position = coordinate
            }
            belBusMarker!.map = self.mapView
            belBusMarker!.title = self.need
        }
    }
    
    func placeMapView(){
        //GMS niet tracken via GMS (gaat niet, Street API nodig maar CoreLocation zou accurater zijn)
        self.camera = GMSCameraPosition.cameraWithLatitude(37.35874528,
            longitude: -122.05241166, zoom: 19)
        mapView.camera = camera
        mapView.delegate = self
        mapView.myLocationEnabled = true
        mapView.mapType = kGMSTypeNormal//kGMSTypeNone
        mapView.myLocationEnabled = true;
        
        self.southWest = CLLocationCoordinate2DMake(50.823978, 3.248864);
        self.northEast = CLLocationCoordinate2DMake(50.825232, 3.251331);
        
        var overlayBounds = GMSCoordinateBounds(coordinate: southWest!, coordinate: northEast!)
        var weide = UIImage(named: "weide")
        var overlay = GMSGroundOverlay(bounds: overlayBounds, icon: weide)
        overlay.bearing = 0
        overlay.map = mapView
        
        self.view = mapView
    }
    
    func socketFunctions(){
        self.socket.connect()
        self.socket.on("connect") {data, ack in
            println("socket connected")
        }
        // logger: self.socket.onAny {println("Got event: \($0.event), with items: \($0.items)")}
    }
    
    func updateLocation(data:NSArray){
        let sid:NSString = data.valueForKey("sid")!.objectAtIndex(0) as! NSString
        let lat:Double = data.valueForKey("lat")!.objectAtIndex(0) as! Double
        let long:Double = data.valueForKey("long")!.objectAtIndex(0) as! Double
        
        var doesContain = self.markers!.filter( { (marker: BusMarker) -> Bool in
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
            self.markers?.append(newMarker)
        }
        if(doesContain.count > 0){
            if(doesContain[0].sid != self.socket.sid){
                if(checkDistance(newCoord)){
                    println("we zijn samen <3")
                }
            }
        }
    }
    
    func checkDistance(helperLoc:CLLocationCoordinate2D)->Bool{
        if((mapView.myLocation) != nil){
            var needingLoc = mapView.myLocation.coordinate
            return GMSGeometryDistance(helperLoc, needingLoc) < 10
        }
        
        return false
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var long = manager.location.coordinate.longitude;
        var lat = manager.location.coordinate.latitude;
        if((self.socket.sid) != nil && self.roll != "undefined"){
            self.socket.emit("refreshLocation", long, lat, self.socket.sid!, self.roll)
        }
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        //bounds
        var long = mapView.camera.target.longitude
        var lat = mapView.camera.target.latitude
        var minLat = southWest!.latitude
        var maxLat = northEast!.latitude
        var minLong = southWest!.longitude
        var maxLong = northEast!.longitude
        //map beperken tot bounds
        /*
        if(long > maxLong || long < minLong || lat > maxLat || lat < minLat){
            println("der over hé gast")
        }
        if(long > maxLong){
            var correctionCamera = GMSCameraPosition.cameraWithLatitude(lat,
                longitude: maxLong, zoom: mapView.camera.zoom)
            mapView!.animateToCameraPosition(correctionCamera)
        }
        
        if(long < minLong){
            var correctionCamera = GMSCameraPosition.cameraWithLatitude(lat,
                longitude: minLong, zoom: mapView.camera.zoom)
            mapView!.animateToCameraPosition(correctionCamera)
        }
        
        if(lat > maxLat){
            var correctionCamera = GMSCameraPosition.cameraWithLatitude(maxLat,
                longitude: long, zoom: mapView.camera.zoom)
            mapView!.animateToCameraPosition(correctionCamera)
        }
        
        if(lat < minLat){
            var correctionCamera = GMSCameraPosition.cameraWithLatitude(minLat,
                longitude: long, zoom: mapView.camera.zoom)
            mapView!.animateToCameraPosition(correctionCamera)
        }
        */
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}