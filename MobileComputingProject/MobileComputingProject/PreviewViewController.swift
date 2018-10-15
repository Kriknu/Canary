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
        //canaryModel.getClosestLibrary(lat: <#T##Double#>, long: <#T##Double#>)
        self.canaryModel.uploadImageToFirebase(imageName, img: self.image)
        self.canaryModel.addMessage(imageName: imageName, type: MessageType.PHOTO)
        performSegue(withIdentifier: "overviewSegue", sender: self)
    }
    @IBOutlet weak var previewImage: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewImage.image = image
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
