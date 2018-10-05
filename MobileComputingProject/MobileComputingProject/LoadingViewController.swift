//
//  LoadingViewController.swift
//  MobileComputingProject
//
//  Created by Carl Albertsson on 2018-10-05.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit
import Lottie

class LoadingViewController: UIViewController {
    
    var timer: Timer!
    
    var animationView: LOTAnimationView = LOTAnimationView(name: "loading_screen_03");

    override func viewDidLoad() {
        super.viewDidLoad()
        
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        
        self.view.addSubview(animationView)
        
        animationView.loopAnimation = true
        
        animationView.play()
        
        timer = Timer.scheduledTimer(timeInterval: 4.5, target: self, selector: #selector(goToMainScreen), userInfo: nil, repeats: true)

    }
    
    @objc func goToMainScreen(){
        performSegue(withIdentifier: "mainScreen", sender: self)
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
