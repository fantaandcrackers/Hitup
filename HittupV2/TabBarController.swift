//
//  TabBarController.swift
//  HitupMe
//
//  Created by Arthur Shir on 9/17/15.
//  Copyright (c) 2015 HitupDev. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    
    // ----- Setup Functions ----- //
    
    func initialSetup() {
        addIntro()
        setupCreateButton()
        setupTabBar()
    }
    
    func addIntro() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let installed: Bool? = defaults.boolForKey("installed_once")
        if (installed == nil || installed == false) {
            let evc = ExplainationViewController(nibName: "ExplainationViewController", bundle: nil)
            //var evc = ExplainationViewController()
            evc.view.frame = view.frame
            introView = evc.view
            evc.doneButton.addTarget(self, action: Selector("removeIntro"), forControlEvents: UIControlEvents.TouchUpInside)
            view.addSubview(evc.view)
            
            defaults.setBool(true, forKey: "installed_once")
        }
        
        
    }
    
    var introView: UIView?
    
    func removeIntro() {
        introView!.removeFromSuperview()
        introView = nil
    }
    
    
    

    
    func setupTabBar() {
        self.tabBar.tintColor = Functions.themeColor()
        self.tabBar.barTintColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        self.tabBar.backgroundImage = UIImage(named: "TabBarBackground")
        self.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        
        //self.tabBar.alpha = 0.7
    }
    
    func setupCreateButton() {
        // Set up CreateButton
        let button = UIButton(frame: CGRectMake(0, 0, self.tabBar.frame.size.width/3, self.tabBar.frame.size.height-1))
        button.center = CGPointMake(self.tabBar.frame.size.width/2, button.center.y)
        button.backgroundColor = UIColor.clearColor()
        //button.layer.shadowOpacity = 0.5
        //button.layer.shadowOffset = CGSizeMake(-1, 3)
        let buttonImage = UIImageView(frame: CGRectMake(0, 3, 38, 38))
        buttonImage.center = CGPointMake(button.frame.size.width/2, buttonImage.center.y)
        buttonImage.image = UIImage(named: "BB_Create")
        button.addSubview(buttonImage)
        self.tabBar.addSubview(button)
        button.addTarget(self, action: Selector("touchCreate"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // ----- Button Functions ----- //
    
    func touchCreate() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let createView = storyboard.instantiateViewControllerWithIdentifier("CreateNav")
        presentViewController(createView, animated: true, completion: nil)
    }
    
    /*
    override func viewWillLayoutSubviews() {
        var rect = tabBar.frame
        rect.size.height = 40
        self.tabBar.frame = rect
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
        Functions.updateLocation()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
