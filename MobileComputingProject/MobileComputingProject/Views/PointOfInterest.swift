//
//  PointOfInterest.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-10-03.
//  Copyright © 2018 CIU196. All rights reserved.
//

import Foundation
import UIKit

class PointOfInterestView: UIView{
    //initWithFrame to init view from code
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    //initWithCode to init view from xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //common func to init our view
    private func setupView() {
        backgroundColor = .red
    }
}
