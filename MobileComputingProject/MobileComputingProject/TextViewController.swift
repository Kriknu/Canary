//
//  TextViewController.swift
//  MobileComputingProject
//
//  Created by Carl Albertsson on 2018-10-05.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    
    @IBOutlet weak var textInputField: UITextView!
    @IBOutlet weak var createTextBTN: UIButton!
    
    var canaryModel: CanaryModel = CanaryModel.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textInputField.clipsToBounds = true
        textInputField.layer.cornerRadius = 10.0
        
        textInputField.becomeFirstResponder()
        // Do any additional setup after loading the view.
        
        createTextBTN.addTarget(self, action: #selector(didButtonClick), for: .touchUpInside)
        
    }
    
    @objc func didButtonClick(_ sender: UIButton){
        //TODO: Fetch the text from the textview - Done
        let text: String = textInputField.text
        print("Text: \(text)")
        //TODO: Create an image - Done
        let textImageView: UIImageView = UIImageView.init(frame: self.view.frame)
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(textImageView.frame.size, false, scale)
        //TODO: Update CGPoint to position
        let rect = CGRect(origin: CGPoint(x: 10, y: 10), size: textImageView.frame.size)
        text.draw(in: rect, withAttributes: nil)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //TODO: Upload image to firebase - Done
        //TODO: Upload it to correct folder with correct name
        self.canaryModel.uploadImageToFirebase("text/test.png", img: newImage)
        //TODO: Create a pin
        self.doSegueBack()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func doSegueBack(){
        self.performSegue(withIdentifier: "createTextBack", sender: self)
    }
    @IBAction func closeTextView(_ sender: Any) {
        self.performSegue(withIdentifier: "closeTextView", sender: self)
    }
}
