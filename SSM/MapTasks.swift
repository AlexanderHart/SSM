//
//  MapTasks.swift
//  SSM
//
//  Created by Alexander Hart on 6/14/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit

class MapTasks: NSObject {
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!

    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((status: String, success: Bool) -> Void)) {
        
        if let originLocation = origin, let destinationLocation = destination {

          // Concaternation of directions URL
          var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&mode=walking"
            
            if let routeWaypoints = waypoints {
                directionsURLString += "&waypoints=optimize:true"
                
                for waypoint in routeWaypoints {
                    directionsURLString += "|" + waypoint
                }
            }
            
            //TODO:-Fix this
            directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            //print(directionsURLString)
            
            let directionsURL = NSURL(string: directionsURLString)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let directionsData = NSData(contentsOfURL: directionsURL!) // Retrieve the data from directions URL
                
                do {
                    let dictionary: Dictionary<NSObject, AnyObject> = try! NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers)  as! Dictionary<NSObject, AnyObject>
                    
                    let status = dictionary["status"] as! String
                    
                    if status == "OK" {
                        self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                        self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                        
                        let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                        
                        let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
                        self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                        
                        let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
                        self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                        
                        completionHandler(status: status, success: true)
                    } else {
                        completionHandler(status: status, success: false)
                    }
                }
                
            })

        } else {
            completionHandler(status: "Origin is nil", success: false)
        }
    }
}