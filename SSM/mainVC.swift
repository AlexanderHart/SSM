//
//  testViewController.swift
//  SSM
//
//  Created by Alexander Hart on 7/6/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import MapKit
import WebKit
import Foundation
import Firebase
import CoreLocation
import GoogleMaps
import StoreKit

class mainVC: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    var userA = Users(meetAmount: 5,    status: "",                 taken: "",                  email: "",              name: "",               gender: "",     year: "",
                      firstMajor: "",   firstMinor: "",             secondMajor: "",            secondMinor: "",        urlOne: "",             urlTwo: "",     latitude: "",
                      longitude: "",    destinationLatitude: "",    destinationLongitude: "",   matchKey: "",           otherUserName: "",      otherUserFirstMajor: "",
                      otherUserID: "",  otherUserUrlOne: "",        otherUserUrlTwo: "",        otherUserLatitude: "",  otherUserLongitude: "", releaseDate: 0)
    
    @IBOutlet weak var viewMap:     GMSMapView!
    @IBOutlet weak var mainLabel:   UINavigationItem!
    @IBOutlet weak var meetAmountLabel: UILabel!
    
    
    
    //MARK:- Map Variables
    let bounds                      = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: 40.632705, longitude: -73.956626), coordinate: CLLocationCoordinate2D(latitude: 40.629442, longitude: -73.947545))
    var destinationMarker           : GMSMarker!
    var mapTasks                    = MapTasks()
    var locationManagerss           = loginVC()
    var markersArray                : Array<GMSMarker> = []//.Waypoints
    var originMarker                : GMSMarker!
    var routePolyline               : GMSPolyline!
    var waypointsArray              : Array<String> = []//....Waypoints
    var timer2                      = NSTimer()
    var markers                     = [GMSMarker]()
    var locationManager             = CLLocationManager()
    var list                        = [SKProduct]()
    var p                           = SKProduct()
    let userDefaults                = NSUserDefaults.standardUserDefaults()
    let rootRef                     = FIRDatabase.database().reference()
    var meetAmount                  = 0
    var latitudeString              = ""
    var longitudeString             = ""
    var releaseDate                 = ""
    
    
    
    //MARK:- Main methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Code to update meet amount every 24 hours
        if let lastRetrieval = userDefaults.dictionaryForKey("lastRetrieval") {
            if let lastDate = lastRetrieval["date"] as? NSDate {
                if abs(lastDate.timeIntervalSinceNow) > 86400 { // seconds in 24 hours
                    // Update meet amount by 5
                    self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["meetAmount": (snapshot.value!.objectForKey("meetAmount") as? Int)! + 5])
                    })
                    
                    let lastRetrieval : [NSObject : AnyObject] = [
                        "date" : NSDate()
                    ]
                    
                    userDefaults.setObject(lastRetrieval, forKey: "lastRetrieval")
                    userDefaults.synchronize()
                    
                    let alert = UIAlertController(title: "", message: "Your 5 daily meets have been replenished", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "Thanks", style: UIAlertActionStyle.Destructive, handler: { action in
                       
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                // Do nothing, not enough time has elapsed to change labels
                print(lastDate.description)
            }
        }
        else {
            // Make new dictionary and save to NSUserDefaults
            let lastRetrieval : [NSObject : AnyObject] = [
                "date" : NSDate()
            ]
            
            print("test" + lastRetrieval.description)
            
            userDefaults.setObject(lastRetrieval, forKey: "lastRetrieval")
            userDefaults.synchronize()
        }

        
        // Make navigation bar transparent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        
        // Customize map
        viewMap.delegate                = self
        viewMap.mapType                 = kGMSTypeSatellite
        viewMap.layer.cornerRadius      = 25
            
            self.viewMap.hidden = true
            self.locationManager.stopUpdatingLocation()
            
//            // display alert
//            let alert = UIAlertController(title: "Welcome", message: "You must be on Brooklyn College campus to use location services", preferredStyle: UIAlertControllerStyle.Alert)
//            
//            alert.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.Destructive, handler: { action in
//            }))
        
            //self.presentViewController(alert, animated: true, completion: nil)
        

        
       // viewMap.setMinZoom(16, maxZoom: viewMap.maxZoom)
        viewMap.layer.masksToBounds     = true
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.userA.destinationLatitude = snapshot.value!.objectForKey("destinationLatitude") as? String
            self.userA.destinationLongitude = snapshot.value!.objectForKey("destinationLongitude") as? String
            self.userA.latitude = snapshot.value!.objectForKey("latitude") as? String
            self.userA.longitude = snapshot.value!.objectForKey("longitude") as? String
            self.userA.releaseDate = snapshot.value!.objectForKey("releaseDate") as? Int
            self.meetAmount = (snapshot.value!.objectForKey("meetAmount") as? Int)!
        })
       
        
        timer2 = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(getAvailableUsers), userInfo: nil, repeats: true)
        
        // Set up iAP
        if SKPaymentQueue.canMakePayments() {
            let productID:NSSet = NSSet(objects: "ssm.bk.addmeets", "ssm.bk.add7meets", "ssm.bk.add11meets", "ssm.bk.add15meets")
            let request: SKProductsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>) // This is different
            request.delegate = self
            request.start()
        }
        else {
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // This is being written here because logically it makes sense -
        // every time before the mainViewController is about to load, set both views
        // to hidden, then in viewDidAppear, decide which view gets displayed
        self.viewMap.hidden     = true
    
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            self.userA.destinationLatitude = snapshot.value!.objectForKey("destinationLatitude") as? String
            self.userA.destinationLongitude = snapshot.value!.objectForKey("destinationLongitude") as? String
            self.userA.latitude = snapshot.value!.objectForKey("latitude") as? String
            self.userA.longitude = snapshot.value!.objectForKey("longitude") as? String
            self.userA.releaseDate = snapshot.value!.objectForKey("releaseDate") as? Int
            self.meetAmount = (snapshot.value!.objectForKey("meetAmount") as? Int)!
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.meetAmountLabel.text = "Meet Amount: \(meetAmount)"
        
        let seconds = Double(self.userA.releaseDate) // Converted to double
        let timestampDate = NSDate(timeIntervalSince1970: seconds)
        
        _ = timestampDate.description
        
        let releaseDateFormatter = NSDateFormatter()
        releaseDateFormatter.dateFormat = "hh:mm a" //"yyyy-MM-dd HH:mm:ss"
        releaseDate = releaseDateFormatter.stringFromDate(timestampDate)
        
        
        // Show inital location of Brooklyn Campus - FOR FINAL RELEASE
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(40.631261, longitude: -73.952482, zoom: 16.2)
        viewMap.camera = camera
        self.viewMap.animateToBearing(84)
        
        self.viewMap.hidden = false
        // Check to see if the logged in user's matchkey is ever "101",
        // which means that they have been requested for a meet.
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeEventType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if (snapshot.value!.objectForKey("matchKey") as? String)! == "101" {
                let vc1 = matchVC(nibName: "matchVC", bundle: nil)
                vc1.otherUserName = (snapshot.value!.objectForKey("otherUserName") as? String)!
                vc1.profileImageUrlTwo = (snapshot.value!.objectForKey("otherUserUrlOne") as? String)! + "&" + (snapshot.value!.objectForKey("otherUserUrlTwo") as? String)!
                
                self.presentViewController(vc1, animated: true, completion: nil)
            }
        })
        
        
        
        // To show active screen
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeEventType(.Value, withBlock: { snapshot in
            if (snapshot.value!.objectForKey("otherUserID") as? String)! != "" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewControllerWithIdentifier("active")
                    self.presentViewController(controller, animated: true, completion: nil) // self will cause a minor run time error
            }
        })
        
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).removeAllObservers()
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        if bounds.containsCoordinate(position.target) {
            self.viewMap.settings.scrollGestures = true
        } else {
                        self.viewMap.settings.scrollGestures = false
            
                        // display alert
                        let alert = UIAlertController(title: "Oops", message: "You can not leave Brooklyn College Campus", preferredStyle: UIAlertControllerStyle.Alert)
            
                        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Destructive, handler: { action in
                            let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(40.631261, longitude: -73.952482, zoom: 16.2)
                            self.viewMap.camera = camera
                            self.viewMap.animateToBearing(84)
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation
        
        latitudeString = String((location.coordinate.latitude))
        longitudeString = String((location.coordinate.longitude))
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["latitude": latitudeString, "longitude": longitudeString])
    }
    
    func checkMeetAmount(mapView: GMSMapView, didTapMarker marker: GMSMarker) {
        var meetAmount = -1
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            meetAmount = (snapshot.value!.objectForKey("meetAmount") as? Int)!
            
            if meetAmount == 0 {
                
                
                // Display UI Alert
                let alert = UIAlertController(title: "Out of Meets", message: "More meets at " + self.releaseDate + " tomorrow", preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "I'll wait", style: UIAlertActionStyle.Destructive, handler: { action in
                }))
                
                
                alert.addAction(UIAlertAction(title: "Get more", style: UIAlertActionStyle.Destructive, handler: { action in
                    let alert = UIAlertController(title: "Options", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "3 meets for $1.99", style: UIAlertActionStyle.Destructive, handler: { action in
                        for product in self.list {
                            let prodID = product.productIdentifier
                            
                            if prodID == "ssm.bk.addmeets" {
                                self.p = product
                                self.buyProduct()
                                break;
                            }
                        }
                    }))
                    
                    alert.addAction(UIAlertAction(title: "7 meets for $3.99 ", style: UIAlertActionStyle.Destructive, handler: { action in
                        for product in self.list {
                            let prodID = product.productIdentifier
                            
                            if prodID == "ssm.bk.add7meets" {
                                self.p = product
                                self.buyProduct()
                                break;
                            }
                        }
                    }))
                    
                    alert.addAction(UIAlertAction(title: "11 meets for $5.99 ", style: UIAlertActionStyle.Destructive, handler: { action in
                        for product in self.list {
                            let prodID = product.productIdentifier
                            
                            if prodID == "ssm.bk.add11meets" {
                                self.p = product
                                self.buyProduct()
                                break;
                            }
                        }
                    }))
                    
                    alert.addAction(UIAlertAction(title: "15 meets for $7.99", style: UIAlertActionStyle.Destructive, handler: { action in
                        for product in self.list {
                            let prodID = product.productIdentifier
                            
                            if prodID == "ssm.bk.add15meets" {
                                self.p = product
                                self.buyProduct()
                                break;
                            }
                        }
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: { action in
                
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else {
                // Proceed to user profile page
                
                let userProfileViewController = userProfileVC(nibName: "userProfileVC", bundle: nil)
                //userProfileVC.userName = (marker.title)!
                
                var nameArr = (marker.title)!.componentsSeparatedByString(" ")
                let name = nameArr[0]
                let id = nameArr[1]
                
                // Until profile page is perfectly, keep this at ==
                if id != NSUserDefaults.standardUserDefaults().stringForKey("id")! {
                    userProfileViewController.idString = id
                    userProfileViewController.nameString = name
                    userProfileViewController.profileImageUrlString = (marker.snippet)!
                    
                    // Display tapped user's profile page.
                    let newController = UINavigationController(rootViewController: userProfileViewController)
                    self.presentViewController(newController, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "Warning", message: "You can't meet yourself", preferredStyle: UIAlertControllerStyle.Alert)
                    
                    alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Destructive, handler: { action in
                    }))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func getAvailableUsers() {
        let rootRef     = FIRDatabase.database().reference()
        let usersRef    = rootRef.child("users/")   // Container for all users
        
        self.viewMap.clear()
        
        usersRef.queryOrderedByChild("matchKey").observeEventType(.ChildAdded, withBlock: { snapshot in
            if let matchKey = snapshot.value!["matchKey"] as? String {
                if matchKey == "10" {
                    
                    
                    let userTwoProfileURL = (snapshot.value!.objectForKey("urlOne") as! String) + "&" + (snapshot.value!.objectForKey("urlTwo") as! String)
                    
                    // This all has to be stored another way
                    // Store data locally
                    NSUserDefaults.standardUserDefaults().setObject(matchKey, forKey: "matchKey"); // WHY???
                    //NSUserDefaults.standardUserDefaults().setObject(userTwoProfileURL, forKey: "userTwoProfileURL");
                    //NSUserDefaults.standardUserDefaults().setObject(snapshot.value!["name"] as? String, forKey: "otherUserName");
                    //NSUserDefaults.standardUserDefaults().setObject(snapshot.key, forKey: "otherUserID");
                    NSUserDefaults.standardUserDefaults().setObject(snapshot.value!["firstMajor"] as? String, forKey: "otherUserFirstMajor");
                    NSUserDefaults.standardUserDefaults().setObject(snapshot.value!["year"] as? String, forKey: "otherUserFirstyear");
                    //NSUserDefaults.standardUserDefaults().setObject(snapshot.value!["latitude"] as? String, forKey: "otherUserLatitude"); NOT USEFUL
                    NSUserDefaults.standardUserDefaults().synchronize();
                    
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2DMake(Double((snapshot.value!["latitude"] as? String)!)!, Double((snapshot.value!["longitude"] as? String)!)!)
                    marker.appearAnimation = kGMSMarkerAnimationPop
                    
                    
                    
                    NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: userTwoProfileURL)!, completionHandler: { (data, response, error) ->
                        Void in
                        
                        let originalImage = UIImage(data: data!)
                        
                        let smallerImage = self.resizeImage(originalImage!, newWidth: 40, newHeight: 40)
                        
                        marker.icon = smallerImage
                        
                    }).resume()
                    
                    marker.title = (snapshot.value!["name"] as? String)! + " " + (snapshot.key)
                    
                    marker.snippet = userTwoProfileURL
                    marker.map = self.viewMap
                    self.markers.append(marker)
                }
            }
        })
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat, newHeight: CGFloat) -> UIImage {
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newWidth))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func countDownDate() {
        
        _ = NSDate()
    }
    
    func mapView(mapView: GMSMapView, didTapMarker marker: GMSMarker) -> Bool {
            // Check if user has 0 meets left
            checkMeetAmount(mapView, didTapMarker: marker)
            
            return true
    }
    
    func configureMapAndMarkersForRoute() {
        viewMap.camera = GMSCameraPosition.cameraWithTarget(mapTasks.originCoordinate, zoom: 17.0)
        
        originMarker = GMSMarker(position: self.mapTasks.originCoordinate)
        originMarker.map = self.viewMap
        originMarker.icon = UIImage(named: "userOnePic")
        
        destinationMarker = GMSMarker(position: self.mapTasks.destinationCoordinate)
        destinationMarker.map = self.viewMap
        destinationMarker.icon = UIImage(named: "userTwoPic")
        
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
    
    func buyProduct() {
        let pay = SKPayment(product: p)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(pay as SKPayment)
    }
    
    func addMeets(meetCount: Int) {
        var meetAmount = 0
        
        self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            
            meetAmount = (snapshot.value!.objectForKey("meetAmount") as? Int)!
            meetAmount = meetAmount + meetCount
            
            self.rootRef.child("users/").child(NSUserDefaults.standardUserDefaults().stringForKey("id")!).updateChildValues(["meetAmount": meetAmount])
        })        
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        let myProduct = response.products
        
        for product in myProduct {
            list.append(product as SKProduct)
        }
        
        
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("add payment")
        
        for transaction:AnyObject in transactions {
            let trans = transaction as! SKPaymentTransaction
            
            print(trans.error)
            
            switch trans.transactionState {
                
                case .Purchased:
                    print("buy, ok unlock ipa here")
                    print(p.productIdentifier)
                    
                    let prodID = p.productIdentifier as String
                    switch prodID {
                        case "ssm.bk.addmeets":
                            print("Add 3 meets to account")
                            addMeets(3)
                        
                        case "ssm.bk.add7meets":
                            print("Add 7 meets to account")
                            addMeets(7)
                    case "ssm.bk.add11meets":
                        print("Add 11 meets to account")
                        addMeets(11)
                    case "ssm.bk.add15meets":
                        print("Add 15 meets to account")
                        addMeets(15)
                    default:
                        print("iAP not setup")
                    }
                    
                    queue.finishTransaction(trans)
                    break
                    
                case .Failed:
                    print("buy error")
                    queue.finishTransaction(trans)
                    break
                    
                default:
                    print("default")
                    break
                
            }
            
        }
    }
    
    func finishTransaction(trans: SKPaymentTransaction) {
        print("finish trans")
    }

    func paymentQueue(queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("remove trans")
    }
}