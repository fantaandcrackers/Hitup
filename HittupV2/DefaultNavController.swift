//
//  DefaultNavController.swift
//  HitupMe
//
//  Created by Arthur Shir on 8/21/15.
//  Copyright (c) 2015 HitupDev. All rights reserved.
//

import UIKit

class DefaultNavController: UINavigationController {

    var isMap = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.barTintColor = Functions.themeColor()
        self.navigationBar.tintColor = UIColor.whiteColor()
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Avenir-Medium", size: 16)!],
                forState: UIControlState.Normal)
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Avenir-Medium", size: 18)!]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setIsMapTab(isMapTab: Bool) {
        isMap = isMapTab
    }



}
