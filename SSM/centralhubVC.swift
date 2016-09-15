//
//  countDown.swift
//  SSM
//
//  Created by Alexander Hart on 7/1/16.
//  Copyright © 2016 Alexander Hart. All rights reserved.
//

import UIKit
import Firebase

class centralhubVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let profileViewController = profileVC(nibName: "profileVC", bundle: nil)
        //        self.addChildViewController(profileViewController)
        //        self.scrollView.addSubview(profileViewController.view)
        //        profileViewController.didMoveToParentViewController(self)
        //
        //        let mainViewController = mainVC(nibName: "mainVC", bundle: nil)
        //        var frame1 = mainViewController.view.frame
        //        frame1.origin.x = self.view.frame.size.width
        //        mainViewController.view.frame = frame1
        //        self.addChildViewController(mainViewController)
        //        self.scrollView.addSubview(mainViewController.view)
        //        mainViewController.didMoveToParentViewController(self)
        //
        //        let ratingViewController = ratingVC(nibName: "ratingVC", bundle: nil)
        //        var frame2 = ratingViewController.view.frame
        //        frame2.origin.x = self.view.frame.size.width * 2
        //        ratingViewController.view.frame = frame2
        //        self.addChildViewController(ratingViewController)
        //        self.scrollView.addSubview(ratingViewController.view)
        //        ratingViewController.didMoveToParentViewController(self)
        
        
        let profileViewController   = profileVC(nibName: "profileVC", bundle: nil)
        let ratingViewController    =  ratingVC(nibName: "ratingVC", bundle: nil)
        let mainViewController      =    mainVC(nibName: "mainVC", bundle: nil)
        
        self.addChildViewController(profileViewController)
        self.addChildViewController(mainViewController)
        self.addChildViewController(ratingViewController)
        
        self.scrollView.addSubview(profileViewController.view)
        self.scrollView.addSubview(ratingViewController.view)
        self.scrollView.addSubview(mainViewController.view)
        
        profileViewController.didMoveToParentViewController(self)
         ratingViewController.didMoveToParentViewController(self)
           mainViewController.didMoveToParentViewController(self)
        
        var frame1 =   mainViewController.view.frame
        var frame2 = ratingViewController.view.frame
        
        frame1.origin.x = self.view.frame.size.width
        frame2.origin.x = self.view.frame.size.width * 2
        
          mainViewController.view.frame = frame1
        ratingViewController.view.frame = frame2
        
        self.scrollView.contentSize   = CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height)
        self.scrollView.contentOffset = CGPoint(x: self.view.frame.size.width, y :0.0)
    }
}



