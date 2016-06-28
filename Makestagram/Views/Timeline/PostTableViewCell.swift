//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Dylan Steck on 6/28/16.
//  Copyright © 2016 Make School. All rights reserved.
//
import UIKit
import Bond

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var postImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool){
        super.setSelected(selected, animated: animated)
        //Configure the view for the selected state
    }
    
    var post: Post? {
        didSet {
            // Whenever a new value is assigned to the post property, we use optional binding to check whether the new value is nil.
            if let post = post {
                //If the value isn't nil, we create a binding between the image property of the post and the image property of the postImageView using the .bindTo method.
                // bind the image of the post to the 'postImage' view
                post.image.bindTo(postImageView.bnd_image)
            }
        }
    }
}
