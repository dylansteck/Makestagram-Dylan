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
   var posts: [Post] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    var photoTakingHelper: PhotoTakingHelper?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        //This delegate is allowing us to track changes to the items in the tab bar. We set it to self(the timeline view controller), giving it the capabilities of actually tracking the changes(our transition to the photo button)
        self.tabBarController?.delegate = self
    }
    
    //we store the posts, download all of the images, and finally update the table view.
    override func viewDidAppear(animated: Bool) {
        //We no longer want to download all images immediately after the timeline query completes, instead we want to load them lazily as soon as a post is displayed. Now we are only downloading the metadata of all posts upfront and deferring the image download until a post is displayed.c
        super.viewDidAppear(animated)
        
        ParseHelper.timelineRequestForCurrentUser { (result: [PFObject]?, error: NSError?) -> Void in
            self.posts = result as? [Post] ?? []
            
            self.tableView.reloadData()
        }
    }
    func takePhoto() {
        // instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!) { (image: UIImage?) in
            let post = Post()
            // Because image is now an Observable type, we need to store the image using the .value property.
            post.image.value = image!
            post.uploadPost()
        }
    }
}
// MARK: Tab Bar Delegate

extension TimelineViewController: UITabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (viewController is PhotoViewController) {
            takePhoto()
            print("Take Photo")
            return false
        } else {
            return true
        }
    }
}

extension TimelineViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Our Table View needs to have as many rows as we have posts stored in the posts property
        return posts.count
    }
        //The cellForRowAtIndexPath method is called when the table view is about to present a cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // In this line we cast cell to our custom class PostTableViewCell. (In order to access the specific properties of our custom table view cell, we need to perform a cast to the type of our custom class. Without this cast the cell variable would have a type of a plain old UITableViewCell instead of our PostTableViewCell.)
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        let post = posts[indexPath.row]
        // Directly before a post will be displayed, we trigger the image download.
        post.downloadImage()
        // Instead of changing the image that is displayed in the cell from within the TimelineViewController, we assign the post that shall be displayed to the post property. After the changes we made a few steps back, the cell now takes care of displaying the image that belongs to a Post object itself.
        cell.post = post
        
        return cell
    }
}