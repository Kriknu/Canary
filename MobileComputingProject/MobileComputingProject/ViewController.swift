//
//  ViewController.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-09-13.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var floorPlanView: UIImageView!
    @IBOutlet weak var floorPlanScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.floorPlanScrollView.minimumZoomScale = 1.0
        self.floorPlanScrollView.maximumZoomScale = 6.0
        do {
            let url = URL(string:"https://i.imgur.com/DkvC9R6.png")
            let data = try Data.init(contentsOf: url!)
            self.floorPlanView.image = UIImage(data: data)
        }catch{
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.floorPlanView
    }


}

