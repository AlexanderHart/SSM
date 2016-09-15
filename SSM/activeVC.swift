//
//  ViewController.swift
//  SSM
//
//  Created by Alexander Hart on 2/6/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//
//
//
//        East quad
//        let me = CLLocationCoordinate2D(latitude: 40.631430, longitude: -73.951324)
//        let coordinate3 = CLLocationCoordinate2D(latitude: 40.631444, longitude: -73.951738)
//        let coordinate4 = CLLocationCoordinate2D(latitude: 40.631447, longitude: -73.951213)
//        let coordinate5 = CLLocationCoordinate2D(latitude: 40.631418, longitude: -73.953188)
//
//        West quad
//        let coordinate6 = CLLocationCoordinate2D(latitude: 40.631334, longitude: -73.953886)
//        let coordinate7 = CLLocationCoordinate2D(latitude: 40.631300, longitude: -73.953881)
//        let coordinate8 = CLLocationCoordinate2D(latitude: 40.631169, longitude: -73.953852)
//        let coordinate9 = CLLocationCoordinate2D(latitude: 40.630918, longitude: -73.953810)
//

import UIKit
import MapKit
import WebKit
import Foundation
import Firebase
import CoreLocation
import GoogleMaps

class activeVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    var userA = Users(meetAmount: 5,    status: "",                 taken: "",                  email: "",              name: "",               gender: "",     year: "",
                      firstMajor: "",   firstMinor: "",             secondMajor: "",            secondMinor: "",        urlOne: "",             urlTwo: "",     latitude: "",
                      longitude: "",    destinationLatitude: "",    destinationLongitude: "",   matchKey: "",           otherUserName: "",      otherUserFirstMajor: "",
                      otherUserID: "",  otherUserUrlOne: "",        otherUserUrlTwo: "",        otherUserLatitude: "",  otherUserLongitude: "", releaseDate: 0)
    
    @IBOutlet var       viewMap:            GMSMapView!
    @IBOutlet weak var  mainLabel:          UINavigationItem!
    
    // Breaking down the code
    // 1. Display alert, prompting user if they want to continue
    // 2.
    @IBAction func cancelTapped(sender: AnyObject) {
        // Display warning
        let alert = UIAlertController(title: "Warning", message: "Cancelling a meet early will lower your meet limit", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Destructive, handler: { action in
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { snapshot in
                var meetAmount = -1
                var releaseDate: NSNumber
                
                meetAmount = (snapshot.value!.objectForKey("meetAmount") as? Int)!
                meetAmount = meetAmount - 1
                
                // 7.10.16 12:46 - Logical bug found
                //
                // Not sure why I was updating values in the other user ID's object, but I changed
                // it to the currently logged-in user
                if meetAmount == 0 {
                    releaseDate = NSDate().timeIntervalSince1970 + 84000 // 24 hours ahead of time
                    self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["meetAmount": meetAmount, "releaseDate": releaseDate])
                }
                else {
                    releaseDate = 0
                    self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["meetAmount": meetAmount, "releaseDate": releaseDate])
                }
            })
            
            // Update both parties
            self.rootRef.child("users/").child(self.userA.otherUserID).updateChildValues(["otherUserID": "", "matchKey": "10", "otherUserName": "","otherUserLatitude": "", "otherUserLongitude": "", "otherUserUrlOne": "", "otherUserUrlTwo": "", "otherUserFirstMajor": ""])
            
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["otherUserID": "", "matchKey": "10", "otherUserName": "","otherUserLatitude": "", "otherUserLongitude": "", "otherUserUrlOne": "", "otherUserUrlTwo": "", "otherUserFirstMajor": ""])
            
            // Redirect to mainVC
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("testVC")
            self.presentViewController(controller, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Go back", style: UIAlertActionStyle.Destructive, handler: { action in
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    let rootRef =                   FIRDatabase.database().reference()
    var locationManager =           CLLocationManager()
    
    //MARK:- Map Variables
    var originMarker:               GMSMarker!
    var destinationMarker:          GMSMarker!
    var routePolyline:              GMSPolyline!
    var markersArray:               Array<GMSMarker> = []
    var waypointsArray:             Array<String> = []
    var mapTasks =                  MapTasks()
    var latitudeString              = ""
    var longitudeString             = ""
    var releaseDate                 = 0.0
    

    
    // MARK:- Main methods

    // Customize the UI (navBar)
    // Setup map view
    // Get essential data (profile URL's, destination, etc)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make navigation bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        viewMap.delegate = self
        viewMap.mapType = kGMSTypeSatellite
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.userA.destinationLatitude      = (snapshot.value!.objectForKey("destinationLatitude") as? String)!
            self.userA.destinationLongitude     = (snapshot.value!.objectForKey("destinationLongitude") as? String)!
            self.userA.otherUserID              = snapshot.value!.objectForKey("otherUserID") as? String
            self.userA.latitude                 = snapshot.value!.objectForKey("latitude") as? String
            self.userA.longitude                = snapshot.value!.objectForKey("longitude") as? String
            self.userA.otherUserLatitude        = snapshot.value!.objectForKey("otherUserLatitude") as? String
            self.userA.otherUserLongitude       = snapshot.value!.objectForKey("otherUserLongitude") as? String
            self.userA.urlOne                   = snapshot.value!.objectForKey("urlOne") as? String
            self.userA.urlTwo                   = snapshot.value!.objectForKey("urlTwo") as? String
            self.userA.otherUserUrlOne          = snapshot.value!.objectForKey("otherUserUrlOne") as? String
            self.userA.otherUserUrlTwo          = snapshot.value!.objectForKey("otherUserUrlTwo") as? String
            
//            self.userA.otherUserID              = snapshot.value!.objectForKey("otherUserID") as? String
//            self.userA.latitude                 = snapshot.value!.objectForKey("latitude") as? String
//            self.userA.longitude                = snapshot.value!.objectForKey("longitude") as? String
//            self.userA.urlOne                   = snapshot.value!.objectForKey("urlOne") as? String
//            self.userA.urlTwo                   = snapshot.value!.objectForKey("urlTwo") as? String
        })
    }
    
    // Setup location services
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        locationManager.startUpdatingLocation()
    }
    
    // Using the data from viewDidLoad, request JSON data from Google
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let origin = self.userA.latitude + "," + self.userA.longitude
        let destination = self.userA.otherUserLatitude + "," + self.userA.otherUserLongitude
        
        self.waypointsArray.append(self.userA.destinationLatitude + "," + self.userA.destinationLongitude)
        
        self.mapTasks.getDirections(origin, destination: destination, waypoints: self.waypointsArray, travelMode: nil, completionHandler: { (status, success) -> Void in
            if success {
                self.configureMapAndMarkersForRoute()
                self.drawRoute()
            }
        })
        
        // Recurringly check to see if otherUserID is nil, signifying that the other user cancelled the meet.
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeEventType(FIRDataEventType.Value, withBlock: { snapshot in
            let otherUID = (snapshot.value!.objectForKey("otherUserID") as? String)
            
            if otherUID == "" {
                // Display warning
                let alert = UIAlertController(title: "Warning", message: "Partner is now unavailable", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Destructive, handler: { action in
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("testVC")
                    self.presentViewController(controller, animated: true, completion: nil)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })

    }
    
    // Remove all observers
    override func viewDidDisappear(animated: Bool) {
        self.rootRef.child("users/").child(self.userA.otherUserID).removeAllObservers()
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).removeAllObservers()
    }
    
    
    
    //Mark:- Location
    // Breaking down the code
    // 1. Every time a new location is detected with the GPS sensor...
    // 2. Store a string version of the coordinate for external scope
    // 3. Update database of logged in user with defined variables
    // 4. Check to see if the newly updated coordinate is within a given range.
            // 4.5 If so, then present count view controller
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        latitudeString = String((location.coordinate.latitude))
        longitudeString = String((location.coordinate.longitude))
    
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["latitude": latitudeString, "longitude": longitudeString])
        
        let radius = 0.00008938873734
        
        // Acceptable ranges that will be considered arrived at the desitination
        if (location.coordinate.latitude) < (Double(self.userA.destinationLatitude)! + radius) && (location.coordinate.latitude) > (Double(self.userA.destinationLatitude)! - radius) {
            if (location.coordinate.longitude) > (Double(self.userA.destinationLongitude)! - radius) && (location.coordinate.longitude) < (Double(self.userA.destinationLongitude)! + radius) {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("count")
                self.presentViewController(controller, animated: true, completion: nil)
                // 7/10/16 12:35 a.m. - Found a logical bug.
                // 
                // This should not be here because countVC
                // needs to know the user's location when
                // they choose to display certain data
                //locationManager.stopUpdatingLocation()
                
                // For debugging - 8.16.16
                print("\(location.coordinate.latitude),\(location.coordinate.longitude) is acceptable")
                
                locationManager.stopUpdatingLocation()
                
            }
        } else {
            // For debugging - 8.16.16
            print("\(location.coordinate.latitude),\(location.coordinate.longitude) is not acceptable")
        }
    }

    
    
    //Mark:- Other
    func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newWidth))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
    
    //MARK:- GMS methods
    func configureMapAndMarkersForRoute() {
        viewMap.camera = GMSCameraPosition.cameraWithTarget(mapTasks.originCoordinate, zoom: 17.0)
        
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.viewMap
        
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: self.userA.urlOne + "&" + self.userA.urlTwo)!, completionHandler: { (data, response, error) ->
            Void in
            
            self.originMarker.icon = self.resizeImage(UIImage(data: data!)!, newWidth: 25, newHeight: 25)
            
        }).resume()
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.viewMap
        
        
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: self.userA.otherUserUrlOne + "&" + self.userA.otherUserUrlTwo)!, completionHandler: { (data, response, error) ->
            Void in
            self.destinationMarker.icon = self.resizeImage(UIImage(data: data!)!, newWidth: 25, newHeight: 25)
        }).resume()
        
        if waypointsArray.count > 0 {
            for waypoint in waypointsArray {
                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = viewMap
                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
                
                markersArray.append(marker)
            }
        }
    }
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepCapacity: false)
        }
    }
    
    func drawRoute() {
        let route = mapTasks.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 5.0
        routePolyline.map = viewMap
        routePolyline.strokeColor = UIColor(red: (136/255.0), green: (35/255.0), blue: (69/255.0), alpha: 0.7)
    }
}