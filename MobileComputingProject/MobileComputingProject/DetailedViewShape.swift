//
//  DetailedViewShape.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-10-08.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit

class DetailedViewShape: UIView {
    
    var bgColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.4)

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
        bezierPath.move(to: CGPoint(x: 1, y: 3.63))
        bezierPath.addCurve(to: CGPoint(x: 1, y: 73.31), controlPoint1: CGPoint(x: 1, y: 11.37), controlPoint2: CGPoint(x: 1, y: 73.31))
        bezierPath.addCurve(to: CGPoint(x: 6.57, y: 75.89), controlPoint1: CGPoint(x: 1, y: 73.31), controlPoint2: CGPoint(x: 0.96, y: 75.89))
        bezierPath.addCurve(to: CGPoint(x: 62.29, y: 75.89), controlPoint1: CGPoint(x: 28.86, y: 75.89), controlPoint2: CGPoint(x: 50.85, y: 75.89))
        bezierPath.addCurve(to: CGPoint(x: 73.43, y: 75.89), controlPoint1: CGPoint(x: 63, y: 75.89), controlPoint2: CGPoint(x: 69.83, y: 75.89))
        bezierPath.addCurve(to: CGPoint(x: 79, y: 78.47), controlPoint1: CGPoint(x: 79, y: 75.89), controlPoint2: CGPoint(x: 79, y: 80.53))
        bezierPath.addCurve(to: CGPoint(x: 79, y: 3.63), controlPoint1: CGPoint(x: 79, y: 59.88), controlPoint2: CGPoint(x: 79, y: 13.23))
        bezierPath.addCurve(to: CGPoint(x: 73.43, y: 1.05), controlPoint1: CGPoint(x: 79, y: 1.11), controlPoint2: CGPoint(x: 79, y: 1.05))
        bezierPath.addCurve(to: CGPoint(x: 6.57, y: 1.05), controlPoint1: CGPoint(x: 51.14, y: 1.05), controlPoint2: CGPoint(x: 6.57, y: 1.05))
        bezierPath.addCurve(to: CGPoint(x: 1, y: 3.63), controlPoint1: CGPoint(x: 6.57, y: 1.05), controlPoint2: CGPoint(x: 1, y: 0.42))
        
        bgColor.setFill()
        bezierPath.fill()
        UIColor.black.setStroke()
        bezierPath.lineWidth = 0.5
        bezierPath.stroke()
    }

}
