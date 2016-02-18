//
//  RiderViewController.swift
//  Uber
//
//  Created by Lamar Greene on 2/5/16.
//  Copyright © 2016 Lamar Greene. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var locationManager: CLLocationManager!
    
    var latitude: CLLocationDegrees = 0
    
    var longitude: CLLocationDegrees = 0
    
    var riderRequestActive = false
    
    var driverOnTheWay = false
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var callUberButton: UIButton!
    
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
        
            var riderRequest = PFObject(className: "riderRequest")
            riderRequest["username"] = PFUser.currentUser()?.username
            riderRequest["location"] = PFGeoPoint(latitude: latitude, longitude: longitude)
            
            riderRequest.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    
                    self.callUberButton.setTitle("Cancel Uber", forState: .Normal)
                    
                    self.riderRequestActive = true

                    
                } else {
                    
                    var alert = UIAlertController(title: "Could not call Uber", message: "Please try again!", preferredStyle: .Alert)
                    var alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alert.addAction(alertAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
            }
        
        
        
        } else {
            
            self.riderRequestActive = false
            self.callUberButton.setTitle("Call an Uber", forState: .Normal)
        
            var query = PFQuery(className: "riderRequest")
            query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
            query.findObjectsInBackgroundWithBlock({ (objects, error: NSError?) -> Void in
                
                if error == nil {
                
                if let objects = objects {
                
                    for object in objects {
                        
                        object.deleteInBackground()
                    
                    }
                
                }
                    
                } else {
                    
                    print(error)
                
                }
                
            })
        
        
        }
        

        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var location: CLLocationCoordinate2D = locationManager.location!.coordinate
        
        self.latitude = location.latitude
        self.longitude = location.longitude

        
        var query = PFQuery(className: "riderRequest")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock({ (objects, error: NSError?) -> Void in
            
            if error == nil {
                
                if let objects = objects {
                    
                    for object in objects {
                        
                        if let driverUsername = object["driverResponded"] {
                            
                            var query = PFQuery(className: "driverLocation")
                            query.whereKey("username", equalTo: driverUsername)
                            query.findObjectsInBackgroundWithBlock({ (objects, error: NSError?) -> Void in
                                
                                if error == nil {
                                    
                                    if let objects = objects {
                                        
                                        for object in objects {
                                            
                                            if let driverLocation = object["driverLocation"] as? PFGeoPoint {
                                                
                                                
                                                let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                
                                                let userCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                                
                                                let distanceMeters = userCLLocation.distanceFromLocation(driverCLLocation)
                                                let distanceKm = distanceMeters / 1000
                                                let roundedTwoDigitDistance = Double(round(distanceKm * 100) / 100)
                                                
                                                self.callUberButton.setTitle("Driver is \(roundedTwoDigitDistance) km away!", forState: .Normal)
                                                
                                                
                                                self.driverOnTheWay = true
                                                
                                                let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                                                
                                                var latDelta = abs(driverLocation.latitude - location.latitude) * 2 + 0.001
                                                var lonDelta = abs(driverLocation.longitude - location.longitude) * 2 + 0.001
                                                
                                                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                                
                                                self.map.setRegion(region, animated: true)
                                                
                                                self.map.removeAnnotations(self.map.annotations)
                                                
                                                var pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                                                var objectAnnotation = MKPointAnnotation()
                                                objectAnnotation.coordinate = pinLocation
                                                objectAnnotation.title = "Your Location"
                                                self.map.addAnnotation(objectAnnotation)
                                                
                                                pinLocation = CLLocationCoordinate2DMake(driverLocation.latitude, driverLocation.longitude)
                                                objectAnnotation = MKPointAnnotation()
                                                objectAnnotation.coordinate = pinLocation
                                                objectAnnotation.title = "Driver Location"
                                                self.map.addAnnotation(objectAnnotation)
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            })

                        }
                    }
                }
            }
            })
        
        
        
        if driverOnTheWay == false {
        
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.map.setRegion(region, animated: true)
        
        self.map.removeAnnotations(map.annotations)
        
        var pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        var objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        objectAnnotation.title = "Your Location"
        self.map.addAnnotation(objectAnnotation)
        
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutRider" {

            PFUser.logOut()
            var currentUser = PFUser.currentUser()
            print(currentUser)
            locationManager.stopUpdatingLocation()
        
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
