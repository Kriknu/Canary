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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textInputField.clipsToBounds = true
        textInputField.layer.cornerRadius = 10.0
        
        textInputField.becomeFirstResponder()
        // Do any additional setup after loading the view.
        
        createTextBTN.addTarget(self, action: #selector(didButtonClick), for: .touchUpInside)
        
    }
    
    @objc func didButtonClick(_ sender: UIButton){
        //TODO: Add functionality to uppload the image and create a pin
        self.doSegueBack()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func doSegueBack(){
        self.performSegue(withIdentifier: "createTextBack", sender: self)
    }
}
