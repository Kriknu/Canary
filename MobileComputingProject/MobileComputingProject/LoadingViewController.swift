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
    var animationView: LOTAnimationView = LOTAnimationView(name: "loading_screen_04")

    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        self.view.addSubview(animationView)
        animationView.loopAnimation = true
        animationView.play()
        
        let firstLaunch = FirstLaunch()
        if firstLaunch.isFirstLaunch {
            timer = Timer.scheduledTimer(timeInterval: 4.5, target: self, selector: #selector(goToOnBoardingScreen), userInfo: nil, repeats: true)
        } else {
            timer = Timer.scheduledTimer(timeInterval: 4.5, target: self, selector: #selector(goToMainScreen), userInfo: nil, repeats: true)
        }
    }

    @objc func goToMainScreen(){
        performSegue(withIdentifier: "mainScreen", sender: self)
    }

    @objc func goToOnBoardingScreen() {
        performSegue(withIdentifier: "onBoarding", sender: self)
    }

    final class FirstLaunch {
        let userDefaults: UserDefaults = .standard
        let wasLaunchedBefore: Bool
        var isFirstLaunch: Bool {
            return !wasLaunchedBefore
        }

        init() {
            let key = "com.any-suggestion.FirstLaunch.WasLaunchedBefore"
            let wasLaunchedBefore = userDefaults.bool(forKey: key)
            self.wasLaunchedBefore = wasLaunchedBefore
            if !wasLaunchedBefore {
                userDefaults.set(true, forKey: key)
            }
        }
    }
}
