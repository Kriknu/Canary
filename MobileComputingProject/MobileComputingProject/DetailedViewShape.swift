//
//  DetailedViewShape.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-10-08.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit

class DetailedViewShape: UIView {
    
    let bgColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.0)

    var bezierPath: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.darkGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        self.createShape()
    }
    
    func createShape(){
        bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 37.48, y: 73.38))
        bezierPath.addCurve(to: CGPoint(x: 8.27, y: 60.9), controlPoint1: CGPoint(x: 32.48, y: 71.8), controlPoint2: CGPoint(x: 18.05, y: 72.54))
        bezierPath.addCurve(to: CGPoint(x: 7.67, y: 12.86), controlPoint1: CGPoint(x: 0.85, y: 52.07), controlPoint2: CGPoint(x: -4.61, y: 23.44))
        bezierPath.addCurve(to: CGPoint(x: 80.39, y: 12.86), controlPoint1: CGPoint(x: 30.92, y: -7.16), controlPoint2: CGPoint(x: 62.72, y: -1.16))
        bezierPath.addCurve(to: CGPoint(x: 80.99, y: 60.9), controlPoint1: CGPoint(x: 94.7, y: 24.21), controlPoint2: CGPoint(x: 94.17, y: 43.74))
        bezierPath.addCurve(to: CGPoint(x: 58.93, y: 73.38), controlPoint1: CGPoint(x: 75.28, y: 68.34), controlPoint2: CGPoint(x: 67.46, y: 70.54))
        bezierPath.addCurve(to: CGPoint(x: 47.01, y: 80), controlPoint1: CGPoint(x: 49.99, y: 76.36), controlPoint2: CGPoint(x: 47.01, y: 80))
        bezierPath.addCurve(to: CGPoint(x: 37.48, y: 73.38), controlPoint1: CGPoint(x: 47.01, y: 80), controlPoint2: CGPoint(x: 43.44, y: 75.27))
        bezierPath.close()
        
        bgColor.setFill()
        bezierPath.fill()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
    }

}
