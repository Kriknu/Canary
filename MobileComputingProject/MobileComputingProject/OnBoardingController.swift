//
//  OnBoardingController.swift
//  MobileComputingProject
//
//  Created by Carl Albertsson on 2018-10-17.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit
import Lottie

class OnBoardingController: UIViewController {
    
    var animationView: LOTAnimationView = LOTAnimationView(name: "onBoarding")

    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        self.view.addSubview(animationView)
        animationView.loopAnimation = true
        animationView.play()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func firstTimeEnter(_ sender: Any) {
        enterFirstTime()
    }
    
    @objc func enterFirstTime() {
        self.performSegue(withIdentifier: "enterFirstTime", sender: self)
    }
}
