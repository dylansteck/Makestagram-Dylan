//
//  TimelineViewController.swift
//  Makestagram
//
//  Created by Dylan Steck on 6/23/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Parse

class TimelineViewController: UIViewController {
    
    var photoTakingHelper: PhotoTakingHelper?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.delegate = self
    }
    
    func takePhoto(){
        //instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!){(image: UIImage?) in
            if let image = image{
                let imageData = UIImageJPEGRepresentation(image, 0.8)!
                let imageFile = PFFile(name: "image.jpg", data: imageData)!
                
                let post = PFObject(className: "Post")
                post["imageFile"] = imageFile
                post.saveInBackground()
                
            }
        }
    }
}

// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            takePhoto()
            return false
        } else {
            return true
        }
    }
}