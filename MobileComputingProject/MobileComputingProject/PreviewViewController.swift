//
//  PreviewViewController.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-10-15.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    var canaryModel = CanaryModel.sharedInstance

    @IBAction func cancelPreview(_ sender: Any) {
        performSegue(withIdentifier: "newPhotoSegue", sender: self)
    }
    @IBAction func donePreview(_ sender: Any) {
        let imageName = self.canaryModel.getImageName()
        self.previewImage.transform = CGAffineTransform(rotationAngle: (0.5 * .pi))
        self.canaryModel.uploadImageToFirebase(imageName, img: self.previewImage.image)
        self.canaryModel.addMessage(imageName: imageName, type: MessageType.PHOTO)
        performSegue(withIdentifier: "overviewSegue", sender: self)
    }
    @IBOutlet weak var previewImage: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewImage.contentMode = UIViewContentMode.scaleAspectFit
        previewImage.image = image
        // Do any additional setup after loading the view.
    }
}
