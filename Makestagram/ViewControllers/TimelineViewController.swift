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
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //  creating the query that fetches the Follow relationships for the current user.
        let followingQuery = PFQuery(className: "Follow")
        followingQuery.whereKey("fromUser", equalTo:PFUser.currentUser()!)
        
        // use that query to fetch any posts that are created by users that the current user is following.
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey("user", matchesKey: "toUser", inQuery: followingQuery)
        
        // create another query to retrieve all posts that the current user has posted.
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey("user", equalTo: PFUser.currentUser()!)
        
        // create a combined query of the 2. and 3. queries using the orQueryWithSubqueries method. The query generated this way will return any Post that meets either of the constraints of the queries in 2. or 3.
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        // define that the combined query should also fetch the PFUser associated with a post. As you might remember, we are storing a pointer to a user object in the user column of each post. By using the includeKey method we tell Parse to resolve that pointer and download all the information about the user along with the post. We will need the username later when we display posts in our timeline.
        query.includeKey("user")
        // define that the results should be ordered by the createdAt field. This will make posts on the timeline appear in chronological order.
        query.orderByDescending("createdAt")
        
        // kick off the network request.
        query.findObjectsInBackgroundWithBlock {(result: [PFObject]?, error: NSError?) -> Void in
            // In the completion block we receive all posts that meet our requirements. The Parse framework hands us an array of type [PFObject]?. However, we would like to store the posts in an array of type [Post]. In this step we check if it is possible to cast the result into a [Post]; if that's not possible (e.g. because the result is nil) we store an empty array ([]) in self.posts. The ?? operator is called the nil coalescing operator in Swift. If the statement before this operator returns nil, the return value will be replaced with the value after the operator.
            self.posts = result as? [Post] ?? []
            // Once we have stored the new posts, we refresh the tableView.
            self.tableView.reloadData()
        }
    }
    
    func takePhoto(){
        //instantiate photo taking class, provide callback for when photo is selected
        photoTakingHelper = PhotoTakingHelper(viewController: self.tabBarController!){(image: UIImage?) in
           let post = Post()
            post.image = image
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
        // For now we return a simple placeholder cell with the title "Post"
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell")!
        
        cell.textLabel!.text = "Post"
        
        return cell
    }
}