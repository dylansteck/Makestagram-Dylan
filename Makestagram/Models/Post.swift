//
//  Post.swift
//  Makestagram
//
//  Created by Dylan Steck on 6/24/16.
//  Copyright © 2016 Make School. All rights reserved.
//
import Foundation
import Parse
import Bond

// 1 To create a custom Parse class you need to inherit from PFObject and implement the PFSubclassing protocol
class Post : PFObject, PFSubclassing {
  
    
    // 2 Next, define each property that you want to access on this Parse class. For our Post class that's the user and the imageFile of a post. That will allow you to change the code that accesses properties through strings post["imageFile"] = imageFile into code that uses Swift properties post.imageFile = imageFile. Notice that we prefixed the properties with @NSManaged. This tells the Swift compiler that we won't initialize the properties in the initializer, because Parse will take care of it for us.
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    
    //Ok, so what is this whole Observable thing? Basically it is just a wrapper around the actual value that we want to store. That wrapper allows us to listen for changes to the wrapped value. The Observable wrapper enables us to use the property together with bindings. You can see the type of the wrapped value in the angled brackets (<UIImage?>). These angled brackets mark the use of generics; a concept that we don't need to discuss now.
    
    var image: Observable<UIImage?> = Observable(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    
    //MARK: PFSubclassing Protocol
    
    // 3 By implementing the parseClassName static function, you create a connection between the Parse class and your Swift class.
    static func parseClassName() -> String {
        return "Post"
    }
    
    // 4 init and initialize are purely boilerplate code - copy these two into any custom Parse class that you're creating.
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    func uploadPost() {
        
        if let image = image.value {
            
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
                 // any uploaded post should be associated with the current user
            user = PFUser.currentUser()
            self.imageFile = imageFile
             //  create a background task. When a background task gets created iOS generates a unique ID and returns it. We store that unique id in the photoUploadTask property. The API requires us to provide an expirationHandler in the form of a closure. That closure runs when the extra time that iOS permitted us has expired. In case the additional background time wasn't sufficient, we are required to cancel our task! Within this block you should delete any temporary resources that you created - in the case of our photo upload we don't have any. Additionally you have to call UIApplication.sharedApplication().endBackgroundTask, otherwise your app will be terminated!
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            // After we've created the background task we save the post and imageFile by calling saveInBackgroundWithBlock(); however, this time we aren't handing nil as a completion handler!
            saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                   // Within the completion handler of saveInBackgroundWithBlock() we inform iOS that our background task is completed. This block gets called as soon as the image upload is finished. The API for background jobs makes us responsible for calling UIApplication.sharedApplication().endBackgroundTask as soon as our work is completed.
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }
    
    func downloadImage() {
        // if image is not downloaded yet, get it
        // First, we check if image.value already has a stored value. We do this to avoid downloading images multiple times. (We only want to start the donwload if image.value is nil.)
        if (image.value == nil) {
            // Here we start the download. Instead of using getData we are using getDataInBackgroundWithBlock - that way we are no longer blocking the main thread!
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    // Once the download completes, we update the post.image. Note that we are now using the .value property, because image is an Observable.
                    self.image.value = image
                }
            }
        }
    }
    
    
}