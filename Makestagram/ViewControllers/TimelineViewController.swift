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
        super.viewDidAppear(animated)
        
        ParseHelper.timelineRequestForCurrentUser {
            (result: [PFObject]?, error: NSError?) -> Void in
            self.posts = result as? [Post] ?? []
            
            for post in self.posts {
                do {
                    let data = try post.imageFile?.getData()
                    post.image.value = UIImage(data: data!, scale:1.0)
                } catch {
                    print("could not get image")
                }
            }
            
            self.tableView.reloadData()
        }
    }
    func takePhoto(){
        //instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!){(image: UIImage?) in
           let post = Post()
            post.image.value = image
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // In this line we cast cell to our custom class PostTableViewCell. (In order to access the specific properties of our custom table view cell, we need to perform a cast to the type of our custom class. Without this cast the cell variable would have a type of a plain old UITableViewCell instead of our PostTableViewCell.)
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as! PostTableViewCell
        
        // Using the postImageView property of our custom cell we can now decide which image should be displayed in the cell.
        cell.postImageView.image = posts[indexPath.row].image.value
        
        return cell
    }
}