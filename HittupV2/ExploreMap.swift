//
//  ExploreMap.swift
//  HitupMe
//
//  Created by Arthur Shir on 9/10/15.
//  Copyright (c) 2015 HitupDev. All rights reserved.
//

import UIKit
import MapKit

class ExploreMap: UIViewController, MKMapViewDelegate {
    
    var hitupToSend = PFObject(className: "Hitups")
    var activeOnly = true
    var todayOnly = true
    var groupMode = false
    
    func initialSetup() {
        let pan = UIPanGestureRecognizer(target: self, action: Selector("pan:"))
        filterSwitch.addGestureRecognizer(pan)
        filterSwitch.setNeedsLayout()
        filterSwitch.layoutIfNeeded()
        filterFrame = filterSwitch.frame
        
        //self.edgesForExtendedLayout = UIRectEdge.None
        
        // Set Shadows
        filterSwitch.layer.masksToBounds = false
        filterSwitch.layer.shadowOpacity = 0.5
        filterSwitch.layer.shadowOffset = CGSizeMake(-1, 3)
        let font = UIFont(name: "Avenir-Medium", size: 13)!
        let attributes: [NSString : AnyObject] = [NSFontAttributeName: font ]
        filterSwitch.setTitleTextAttributes(attributes, forState: UIControlState.Normal)
        
        
//        let shadowView = UIView(frame: CGRectMake(filterSwitch.frame.origin.x + 2, filterSwitch.frame.origin.y + 2 + 20, filterSwitch.frame.width - 4, filterSwitch.frame.height - 4))
//        shadowView.backgroundColor = UIColor.whiteColor()
//        shadowView.layer.shadowOpacity = 0.5
//        shadowView.layer.shadowPath = CGPathCreateWithRect( CGRectMake(filterSwitch.frame.origin.x, filterSwitch.frame.origin.y + 20, filterSwitch.frame.width, filterSwitch.frame.height), nil)
//        shadowView.layer.shadowOffset = CGSizeMake(-1, 3)
//        shadowView.layer.masksToBounds = false
//        view.insertSubview(shadowView, belowSubview: filterSwitch)
//        
        refreshButton.layer.shadowOpacity = 0.5
        refreshButton.layer.shadowOffset = CGSizeMake(-1, 3)
        
    }
    
    func pan(recognizer: UIPanGestureRecognizer) {
        
        if (recognizer.state == UIGestureRecognizerState.Changed) {
            let translation = recognizer.translationInView(self.view)

            var newFrame = recognizer.view!.frame
            newFrame.origin.x += translation.x
            recognizer.view!.frame = newFrame
            filterFrame = newFrame
            
            recognizer.setTranslation(CGPointZero, inView: self.view)
        }
    }
    
    
    var filterFrame : CGRect?
    @IBOutlet var filterSwitch: UISegmentedControl!
    @IBOutlet var centralMapView: MKMapView!

    @IBOutlet var refreshButton: UIButton!
    @IBAction func refreshTouch(sender: AnyObject) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 3, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.refreshButton.transform = CGAffineTransformMakeRotation(CGFloat(2*M_PI))
            }) { (Bool) -> Void in
                self.refreshButton.transform =  CGAffineTransformMakeRotation(CGFloat(0))
        }
        
        Functions.updateLocation()
        refreshMap { (success) -> Void in
        }
    }
    @IBAction func switchChange(sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        
        if (sender.selectedSegmentIndex == 0) {
            // Today
            activeOnly = true
            todayOnly = true
            refreshMap({ (success) -> Void in
                
            })
        } else if ( sender.selectedSegmentIndex == 1) {
            // Active
            activeOnly = false
            todayOnly = true
            refreshMap({ (success) -> Void in
                
            })
        } else {
            // All
            activeOnly = false
            todayOnly = false
            refreshMap({ (success) -> Void in
                
            })
        }
    }
    
    func clearMap() {
        self.centralMapView.removeAnnotations(self.centralMapView.annotations)
        self.centralMapView.showsUserLocation = true
    }
    
    func setSegmentCounts(objects: [PFObject]) {
        // Set Ongoing/Today/Week Count
        var ongoing = 0
        var today = 0
        var week = 0
        for hitup in objects {
            // Hitup isn't passed yesterday
            let expireDate = hitup.objectForKey("expire_time") as? NSDate
            if ( NSDate().compare(expireDate!) == NSComparisonResult.OrderedAscending ) {
                ongoing++
            }
            let yesterday = NSDate().dateByAddingTimeInterval(-86400)
            // Hitup isn't passed yesterday
            if (yesterday.compare(hitup.createdAt!) == NSComparisonResult.OrderedAscending ) {
                today++
            }
            week++
        }
        self.filterSwitch.setTitle(String(format: "Ongoing (%i)", arguments: [ongoing]), forSegmentAtIndex: 0)
        self.filterSwitch.setTitle(String(format: "Today (%i)", arguments: [today]), forSegmentAtIndex: 1)
        self.filterSwitch.setTitle(String(format: "Week (%i)", arguments: [week]), forSegmentAtIndex: 2)
    }
    
    func fillMapWith(hitups: [PFObject]) {
        
        // Remove old Annotations
        print( hitups.count, "Objects")
        clearMap()
        
        // Add annotations to the map
        for hitup in hitups {
            let thisHitup = hitup
            let coords = thisHitup.objectForKey("coordinates") as! PFGeoPoint
            
            let annotation = HitupAnnotation()
            let header = thisHitup.objectForKey("header") as? String
            let users_joined = thisHitup.objectForKey("users_joined") as! [AnyObject]
            
            annotation.title = header
            annotation.subtitle = String(format: "%i joined", (users_joined.count - 1) )
            //annotation.subtitle = host
            annotation.coordinate = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
            annotation.hitup = thisHitup

            self.centralMapView.addAnnotation(annotation)
        }
        
        // Center the Map
        if self.centralMapView.annotations.count <= 1 {
            self.centerMapOnLocation(CLLocationCoordinate2D(latitude: LocationManager.sharedInstance.lat, longitude: LocationManager.sharedInstance.lng))
        } else {
            self.centralMapView.showAnnotations(self.centralMapView.annotations, animated: true)
        }

    }
    
    func refreshMap( completion: (( success: Bool? ) -> Void)) {
        if PermissionRelatedCalls.locationEnabled() == true {
            
//            HighLevelCalls.updateExploreHitups(activeOnly, isTodayOnly: todayOnly, completion: { (success, objects) -> Void in
            HighLevelCalls.updateExploreHitups(false, isTodayOnly: false, completion: { (success, objects) -> Void in
            
                if success == true {
                    if let objects = objects as? [PFObject] {
                        
                        // Set Ongoing/Today/Week Count
                        self.setSegmentCounts(objects)
                        
                        // Set Hitups to be shown
                        var toBeShown = [PFObject]()
                        if self.activeOnly {
                            for hitup in objects {
                                // Hitup isn't passed yesterday
                                let expireDate = hitup.objectForKey("expire_time") as? NSDate
                                if ( NSDate().compare(expireDate!) == NSComparisonResult.OrderedAscending ) {
                                    toBeShown.append(hitup)
                                }
                            }
                        } else if self.todayOnly == true {
                            for hitup in objects {
                                let yesterday = NSDate().dateByAddingTimeInterval(-86400)
                                // Hitup isn't passed yesterday
                                if (yesterday.compare(hitup.createdAt!) == NSComparisonResult.OrderedAscending ) {
                                    toBeShown.append(hitup)
                                }
                            }
                        } else {
                            toBeShown = objects
                        }
                        
                        
                        self.fillMapWith(toBeShown)
                        completion(success: true )
                    } else {
                        self.clearMap()
                        completion(success: false)
                    }
                } else {
                    completion(success: false )
                }
            }) // updateNearbyHitups
            
        } // Location enabled
        else {
            Functions.promptLocationTo(self, message: "Aw 💩! Please enable location to see Hitups.")
            Functions.updateLocation()
            completion(success: false)
        }
    }
    
    // Set Radius of Map View
    var regionRadius: CLLocationDistance = 6000
    func centerMapOnLocation( coords :CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coords, regionRadius * 2.0, regionRadius * 2.0)
        self.centralMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if let userView = centralMapView.viewForAnnotation(userLocation) {
            userView.canShowCallout = false
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if (annotation is MKUserLocation) {
            return nil
            
        } else {
        
            let reuseId = "pin"
            var pinView = centralMapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? HitupAnnotationView
            if pinView == nil {
                pinView = HitupAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            }
            pinView!.canShowCallout = false
            //pinView!.animatesDrop = true
            //pinView!.layer.shadowOpacity = 0.5
            
            let hAnnotation = annotation as! HitupAnnotation
            let hitup = hAnnotation.hitup
            
            
            // Set Active/nonActive
            let expireDate : NSDate? = hitup!.objectForKey("expire_time") as? NSDate
            if (expireDate == nil) {
                //pinView!.pinColor = MKPinAnnotationColor.Red
                pinView!.image = UIImage(named: "PinLocation_0")
            } else {
                if ( NSDate().compare(expireDate!) == NSComparisonResult.OrderedAscending) {
                    //pinView!.pinColor = MKPinAnnotationColor.Green
                    pinView!.image = UIImage(named: "PinLocation_1")
                } else {
                    //pinView!.pinColor = MKPinAnnotationColor.Red
                    pinView!.image = UIImage(named: "PinLocation_0")
                }
            }
            
            if let fb_id = hitup!.objectForKey("user_host") as? String {
                Functions.getSmallPictureFromFBId(fb_id, completion: { (image) -> Void in
                    let imageView = CircularImage(frame: CGRectMake(2, 2, pinView!.frame.width - 4, pinView!.frame.width - 4))
                    
                    // Use CoreGraphics to make round 
                    imageView.layer.cornerRadius = imageView.frame.size.height/2
                    imageView.layer.masksToBounds = true
                    imageView.image = image
                    pinView!.addSubview( imageView )
                })
            }
            pinView!.centerOffset = CGPointMake(0, -pinView!.image!.size.height / 2);
            return pinView
        }
        
    }
    

    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        // Save Hitup to be used in Segue
        let annotation: HitupAnnotation? = view.annotation as? HitupAnnotation
        if (annotation != nil) {
            
            let calloutView = HitupCalloutView.initView()
            calloutView.tag = -1
            calloutView.layer.shadowOpacity = 0.5
            calloutView.layer.shadowOffset = CGSizeMake(-1, 3)
            calloutView.clipsToBounds = false
            
            hitupToSend = annotation!.hitup!
            let hitup = hitupToSend
            let header = hitup.objectForKey("header") as! String
            let name = hitup.objectForKey("user_hostName") as? String
            calloutView.headerLabel.text = header
            calloutView.nameLabel.text = name
            
            // Set Image
            if let fb_id = hitup.objectForKey("user_host") as? String {
                Functions.getPictureFromFBId(fb_id, completion: { (image) -> Void in
                    calloutView.profilePic.image = image
                })
            }
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "M/d"
            let expireDate : NSDate? = hitup.objectForKey("expire_time") as? NSDate
            if (expireDate == nil) {
                calloutView.timeLabel.text = "Ended"
            } else {
                if ( NSDate().compare(expireDate!) == NSComparisonResult.OrderedAscending) {
                    let seconds =  NSDate().timeIntervalSinceDate(expireDate!) * -1
                    calloutView.timeLabel.text = String(format: "%.0f min left", seconds / 60)
                } else {
                    calloutView.timeLabel.text = String(format:"Ended %@", formatter.stringFromDate(expireDate!))
                }
            }
            
            
            let joinedArray = hitup.objectForKey("users_joined") as! [AnyObject]
            calloutView.joinLabel.text = String(format: "%i joined", joinedArray.count - 1)
            
            calloutView.addTarget(self, action: Selector("touchCallout:"), forControlEvents: UIControlEvents.TouchUpInside)
            
            view.addSubview(calloutView)
            
//            let animator = UIDynamicAnimator(referenceView: self.view)
//            let grav = UIGravityBehavior(items: [calloutView])
//            animator.addBehavior(grav)
            
            calloutView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.1, 0.1), CGAffineTransformMakeTranslation(0, calloutView.frame.height/2))
            calloutView.alpha = 0.3
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.15)
            calloutView.transform = CGAffineTransformMakeScale(1.1, 1.1)
            calloutView.alpha = 1
            UIView.commitAnimations()
            UIView.animateWithDuration(0.3, delay: 0.13, usingSpringWithDamping: 0.98, initialSpringVelocity: 1, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                calloutView.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: nil)
        }
    }
    
    /// If user unselects callout annotation view, then remove it.
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        for subView in view.subviews {
            if subView.tag == -1 {
                UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                        subView.alpha = 0.3
                        subView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.8, 0.8), CGAffineTransformMakeTranslation(0, 10))
                    }, completion: { (Bool) -> Void in
                        subView.removeFromSuperview()
                })
            }
        }
    }
    
    var savedCallout: UIView?
    func reenlargenCallout() {
        if savedCallout != nil {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.98, initialSpringVelocity: 1, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.savedCallout!.transform = CGAffineTransformMakeScale(1, 1)
                }, completion: nil)
        }
        
    }
    
    
    func touchCallout(sender: UIView) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.98, initialSpringVelocity: 1, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            sender.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: nil)
        savedCallout = sender
        goToDetail()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        
        centralMapView.delegate = self
        Functions.updateLocationinBack { (success) -> Void in
            if Functions.refreshTab(1) == true {
                self.refreshMap({ (success) -> Void in
                    
                })
            } else {
                
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
        reenlargenCallout()
        
        //facebook
        Functions.updateFacebook { (success) -> Void in
            
        }

        if Functions.refreshTab(1) == true {
            self.refreshMap({ (success) -> Void in
                
            })
        } else {
            
        }
    }
    
    func goToDetail() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewControllerWithIdentifier("MapDetail") as! HitupDetailViewController
        detailVC.thisHitup = hitupToSend
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
}
