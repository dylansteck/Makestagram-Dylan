//
//  PhotoTakingHelper.swift
//  Makestagram
//
//  Created by Dylan Steck on 6/24/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit

//Using the typealias keyword we can provide a function signature with a name. In this case we are saying that a function of type PhotoTakingHelperCallback has one parameter (a UIImage?) and returns Void. This means that any function that wants to be the callback of the PhotoTakingHelper needs to have exactly this signature.
typealias PhotoTakingHelperCallback = UIImage? -> Void

//PhotoTakingHelper has three properties. The first one, viewController, stores a weak reference to a UIViewController. This reference is necessary because the PhotoTakingHelper needs a UIViewController on which it can present other view controllers. It is a weak reference because the PhotoTakingHelper does not own the referenced view controller.
class PhotoTakingHelper : NSObject {
    
    //View controller on which AlertViewController and UIImagePickerController are presented
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
  //The initializer of this class receives the view controller on which we will present other view controllers and the callback that we will call as soon as a user has picked an image.
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback) {
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        //When the class is entirely initialized we immediately call showPhotoSourceSelection(). The method is empty right now, but later it will present the dialog that allows users to choose between their camera and their photo library. Because we call showPhotoSourceSelection() directly from the initializer, the dialog will be presented as soon as we create an instance of PhotoTakingHelper.
        showPhotoSourceSelection()
    }
    
        func showPhotoSourceSelection() {
            // Allow user to choose between photo library and camera
            //set up the UIAlertController by providing it with a message and a preferredStyle. The UIAlertController can be used to present different types of popups. By choosing the .ActionSheet option we create a popup that gets displayed from the bottom edge of the screen.
                 //add different UIAlertActions to the alert controller, each action will result in one additional button on the popup.
            
            let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .ActionSheet)
       
            //creates an alert action for if  the user wants to cancel the request and adds it to the alert controller
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            ////allows the user to pick an image from the library. We create a UIAlertAction for the library and add it to the UIAlertController. (The body of the action is empty right now, but we will add the code in the next section.)
            let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .Default) { (action) in
               self.showImagePickerController(.PhotoLibrary)
            }
            ///We call showImagePickerController and pass either .PhotoLibrary or .Camera as argument - based on the user's choice.
            alertController.addAction(photoLibraryAction)
            
            // Only show camera option if rear camera is available
            //allowing the user to take a new photo, is special because it should only be displayed if the device has access to a camera. We check if the current device has a rear camera by using the isCameraDeviceAvailable(_:) method. If the rear camera is available, we add an action to the alert controller that allows the user to take a new photo
            if (UIImagePickerController.isCameraDeviceAvailable(.Rear)) {
                let cameraAction = UIAlertAction(title: "Photo from Camera", style: .Default) { (action) in
                    self.showImagePickerController(.Camera)
                }
                
                alertController.addAction(cameraAction)
            }
           
            //{resent the alertController. View controllers can only be presented from other view controllers. We use the reference that we've stored in the viewController property and call the presentViewController method on it. Now the popup will be displayed on whichever view controller is stored in the viewController property!
            
            viewController.presentViewController(alertController, animated: true, completion: nil)
        }
    
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        self.viewController.presentViewController(imagePickerController!, animated: true, completion: nil)
    }
    

    
    }
//Two different delegate methods are implemented: One is called when an image is selected, the other is called when the cancel button is tapped.
extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //Within imagePickerControllerDidCancel, the image picker controller is hidden by calling dismissViewControllerAnimated on viewController.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!){
        viewController.dismissViewControllerAnimated(false, completion: nil)
        callback(image)
    }
    //Before we became the delegate of the image picker controller, it was automatically hidden as soon as a user hit the cancel button or selected an image. Now that we are the delegate, we are responsible for hiding it. The imagePickerController(_:didFinishPickingImage:) method is also pretty simple. First we hide the image picker controller, then we call the callback and hand it the image that has been selected as an argument. After this line runs the TimelineViewController will have received the image through its callback closure.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
}


        
     
