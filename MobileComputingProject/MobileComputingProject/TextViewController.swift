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
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var canaryModel: CanaryModel = CanaryModel.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        textInputField.clipsToBounds = true
        textInputField.layer.cornerRadius = 10.0
        textInputField.layer.borderWidth = 1
        textInputField.layer.borderColor = UIColor(displayP3Red: 102.0/255, green: 170.0/255, blue: 179.0/255, alpha: 0.75).cgColor
        
        textInputField.layer.shadowColor = UIColor(displayP3Red: 7.0/255, green: 80.0/255, blue: 90.0/255, alpha: 0.25).cgColor
        textInputField.layer.shadowOpacity = 1
        textInputField.layer.shadowOffset = CGSize(width: 0, height: 1)
        textInputField.layer.shadowRadius = 4

        cancelButton.action = #selector(doSegueBack)
        doneButton.action = #selector(closeTextView)
        
        textInputField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @objc func doSegueBack(){
        self.performSegue(withIdentifier: "closeTextView", sender: self)
    }

    @objc func closeTextView(_ sender: Any) {
        let text: String = textInputField.text
        let textImageView: UIImageView = UIImageView.init(frame: self.view.frame)
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(textImageView.frame.size, false, scale)
        let textFont = UIFont(name: "Helvetica Bold", size: 72)!
        let textFontAttributes = [NSAttributedStringKey.font: textFont,]
        let rect = CGRect(origin: CGPoint(x: 10, y: 10), size: textImageView.frame.size)
        text.draw(in: rect, withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageName = self.canaryModel.getImageName()
        self.canaryModel.uploadImageToFirebase(imageName, img: newImage)
        self.canaryModel.addMessage(imageName: imageName, type: MessageType.TEXT)
        self.performSegue(withIdentifier: "closeTextView", sender: self)
    }
}
