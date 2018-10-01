//
//  PaintViewController.swift
//  MobileComputingProject
//
//  Created by Kristoffer Knutsson on 2018-09-28.
//  Copyright © 2018 CIU196. All rights reserved.
//

import UIKit
import FirebaseStorage

class PaintViewController: UIViewController {

    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var paintView: UIView!
    
    
    var lastPoint = CGPoint.zero
    var color = UIColor.black
    var brushWidth: CGFloat = 10.0
    var opacity: CGFloat = 1.0
    var swiped = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        saveButton.setTitle("Post", for: .normal)
        saveButton.backgroundColor = UIColor.init(red: 230, green: 150, blue: 0, alpha: 0.8)
        saveButton.addTarget(self, action: #selector(PaintViewController.uploadImageToFirebase), for: .touchUpInside)
        //self.buttonView.addSubview(saveButton)
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = false
        lastPoint = touch.location(in: paintView)
    }

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
    // 1
    UIGraphicsBeginImageContext(paintView.frame.size)
    guard let context = UIGraphicsGetCurrentContext() else {
    return
    }
    tempImageView.image?.draw(in: paintView.bounds)
    
    // 2
    context.move(to: fromPoint)
    context.addLine(to: toPoint)
    
    // 3
    context.setLineCap(.round)
    context.setBlendMode(.normal)
    context.setLineWidth(brushWidth)
    context.setStrokeColor(color.cgColor)
    
    // 4
    context.strokePath()
    
    // 5
    tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    tempImageView.alpha = opacity
    UIGraphicsEndImageContext()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        // 6
        swiped = true
        let currentPoint = touch.location(in: paintView)
        drawLine(from: lastPoint, to: currentPoint)
        
        // 7
        lastPoint = currentPoint
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            // draw a single point
            drawLine(from: lastPoint, to: lastPoint)
        }
        
        saveButton.isHidden = false
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: paintView.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView?.image?.draw(in: paintView.bounds, blendMode: .normal, alpha: opacity)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tempImageView.image = nil
    }

    @objc func uploadImageToFirebase(){
        print("Uploading...")
        do {
            print("Do we trigger this function?")
            let storage = Storage.storage()
            let storageReference = storage.reference()
            /*let url = URL(string:"https://cdn.pixabay.com/photo/2014/06/17/08/45/bubble-370270_960_720.png")
            let data = try Data.init(contentsOf: url!)
            let image = UIImage(data: data)
            */
            let image = self.mainImageView.image
            let pngImage: Data? = UIImagePNGRepresentation(image!)					
            var imageRef = storageReference.child("images/test.png")
            _ = imageRef.putData(pngImage ?? Data(), metadata:nil, completion:{(metadata,error) in
                guard let metadata = metadata else{
                    print(error)
                    return
                }
                let downloadUrl = metadata
                print(downloadUrl)
            })
        } catch{
            print(error)
        }
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
